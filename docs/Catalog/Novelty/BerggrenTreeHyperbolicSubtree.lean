import Novelty.BerggrenTreeSilverGrowth

/-!
# Purely hyperbolic subtrees: the abscissa drops below `1`

The abscissa of convergence of the full Berggren tree zeta is `1`
(`Novelty.BerggrenTreeZetaAbscissa`), not the silver value `σ₀`; the reason is that two of
the three branches grow only polynomially (`Lspine_hyp`, `Rspine_hyp`).  This file isolates
the mechanism by removing the parabolic directions.

Consider the free binary subtree spanned by the two blocks

* `MM`  (`blockList true  = [1,1]`), and
* `MR`  (`blockList false = [1,2]`),

each of which contains the hyperbolic Pell move `M`.  Write `blocks bs` for the Berggren
word obtained by concatenating the blocks of a bit string `bs`.  Then:

* `blocks_injective` — distinct bit strings give distinct nodes, so the subtree really is a
  free binary tree inside the ternary Berggren tree;
* `hyp_blocks_lower` / `hyp_blocks_upper` — `5 (5/2)^d ≤ c(blocks bs) ≤ 5 (3+2√2)^{2d}` for
  a bit string of length `d`: every block is *expanding*, unlike the pure `R` direction;
* `summable_subtree` — the subtree zeta converges for `s > log 2 / log(5/2) ≈ 0.7565`;
* `not_summable_subtree` — and diverges for `0 < s < log 2 / log((3+2√2)²) ≈ 0.1963`;
* `subtree_summable_at_one` — in particular it **converges at `s = 1`**, where the full tree
  zeta diverges.

So the abscissa of the hyperbolic subtree lies in `[0.196, 0.757] ⊂ (0,1)`: the silver-type
prediction "abscissa = log(branching)/log(growth)" is qualitatively correct once the
parabolic generators are removed, and the failure of the silver abscissa for the full tree
is entirely due to them.
-/

namespace BerggrenZeta

open Real

/-! ## Part A. The block subtree -/

/-- The two hyperbolic blocks: `true ↦ MM`, `false ↦ MR`. -/
def blockList : Bool → List (Fin 3)
  | true => [1, 1]
  | false => [1, 2]

/-- The Berggren word obtained by concatenating blocks. -/
def blocks : List Bool → List (Fin 3)
  | [] => []
  | b :: bs => blockList b ++ blocks bs

@[simp] theorem blocks_nil : blocks [] = [] := rfl

theorem blocks_cons_true (bs : List Bool) :
    blocks (true :: bs) = (1 : Fin 3) :: (1 : Fin 3) :: blocks bs := rfl

theorem blocks_cons_false (bs : List Bool) :
    blocks (false :: bs) = (1 : Fin 3) :: (2 : Fin 3) :: blocks bs := rfl

theorem blocks_length (bs : List Bool) : (blocks bs).length = 2 * bs.length := by
  induction bs with
  | nil => simp
  | cons b bs ih => cases b <;> simp [blocks_cons_true, blocks_cons_false, ih] <;> ring

/-- Distinct bit strings label distinct nodes of the Berggren tree. -/
theorem blocks_injective : Function.Injective blocks := by
  intro a
  induction a with
  | nil =>
    intro b hb
    cases b with
    | nil => rfl
    | cons c cs => cases c <;> simp [blocks_cons_true, blocks_cons_false] at hb
  | cons x xs ih =>
    intro b hb
    cases b with
    | nil => cases x <;> simp [blocks_cons_true, blocks_cons_false] at hb
    | cons y ys =>
      cases x <;> cases y <;>
        simp only [blocks_cons_true, blocks_cons_false, List.cons.injEq, true_and] at hb
      · rw [ih hb]
      · exact absurd hb.1 (by decide)
      · exact absurd hb.1 (by decide)
      · rw [ih hb]

/-! ## Part B. Every block expands -/

/-- The Pell move multiplies the hypotenuse by at least `5/2`. -/
theorem hyp_M_lower (w : List (Fin 3)) :
    (5 / 2 : ℝ) * (hyp w : ℝ) ≤ (hyp ((1 : Fin 3) :: w) : ℝ) := by
  obtain ⟨h1, h2, -, -⟩ := seed_isSeed w
  have h1' : ((seed w).2 : ℝ) < ((seed w).1 : ℝ) := by exact_mod_cast h1
  have h2' : (0 : ℝ) < ((seed w).2 : ℝ) := by exact_mod_cast h2
  show (5 / 2 : ℝ) * (hyp w : ℝ) ≤ ((hyp ((1 : Fin 3) :: w) : ℕ) : ℝ)
  simp only [hyp, seed_cons, step, mvM]
  push_cast
  nlinarith

/-- The `R` move never decreases the hypotenuse. -/
theorem hyp_R_lower (w : List (Fin 3)) :
    (hyp w : ℝ) ≤ (hyp ((2 : Fin 3) :: w) : ℝ) := by
  obtain ⟨h1, h2, -, -⟩ := seed_isSeed w
  have h1' : ((seed w).2 : ℝ) < ((seed w).1 : ℝ) := by exact_mod_cast h1
  have h2' : (0 : ℝ) < ((seed w).2 : ℝ) := by exact_mod_cast h2
  show (hyp w : ℝ) ≤ ((hyp ((2 : Fin 3) :: w) : ℕ) : ℝ)
  simp only [hyp, seed_cons, step, mvR]
  push_cast
  nlinarith

theorem hyp_pos (w : List (Fin 3)) : (0 : ℝ) < (hyp w : ℝ) := by
  obtain ⟨h1, h2, -, -⟩ := seed_isSeed w
  have : 0 < hyp w := by
    have : 0 < (seed w).2 ^ 2 := by positivity
    simp only [hyp]
    omega
  exact_mod_cast this

/-- One block multiplies the hypotenuse by at least `5/2`. -/
theorem hyp_block_lower (b : Bool) (bs : List Bool) :
    (5 / 2 : ℝ) * (hyp (blocks bs) : ℝ) ≤ (hyp (blocks (b :: bs)) : ℝ) := by
  cases b with
  | true =>
    rw [blocks_cons_true]
    have h1 := hyp_M_lower (blocks bs)
    have h2 := hyp_M_lower ((1 : Fin 3) :: blocks bs)
    have hpos := hyp_pos (blocks bs)
    nlinarith
  | false =>
    rw [blocks_cons_false]
    have h1 := hyp_R_lower (blocks bs)
    have h2 := hyp_M_lower ((2 : Fin 3) :: blocks bs)
    nlinarith

/-- **Exponential lower bound on the subtree.** -/
theorem hyp_blocks_lower (bs : List Bool) :
    5 * (5 / 2 : ℝ) ^ bs.length ≤ (hyp (blocks bs) : ℝ) := by
  induction bs with
  | nil => simp
  | cons b bs ih =>
    have hstep := hyp_block_lower b bs
    have : 5 * (5 / 2 : ℝ) ^ (b :: bs).length
        = (5 / 2 : ℝ) * (5 * (5 / 2 : ℝ) ^ bs.length) := by
      simp [List.length_cons, pow_succ]
      ring
    rw [this]
    nlinarith

/-- **Exponential upper bound on the subtree**, inherited from the silver speed limit. -/
theorem hyp_blocks_upper (bs : List Bool) :
    (hyp (blocks bs) : ℝ) ≤ 5 * (3 + 2 * Real.sqrt 2) ^ (2 * bs.length) := by
  have := hyp_le_silver_pow (blocks bs)
  rwa [blocks_length] at this

/-! ## Part C. The subtree zeta -/

/-- The subtree zeta term, indexed by `(depth in blocks, choice of blocks)`. -/
noncomputable def subtreeTerm (s : ℝ) (p : (d : ℕ) × (Fin d → Bool)) : ℝ :=
  (hyp (blocks (List.ofFn p.2)) : ℝ) ^ (-s)

theorem subtreeTerm_nonneg (s : ℝ) (p : (d : ℕ) × (Fin d → Bool)) : 0 ≤ subtreeTerm s p :=
  Real.rpow_nonneg (le_of_lt (hyp_pos _)) _

/-- **Convergence of the hyperbolic subtree zeta** above `log 2 / log(5/2)`. -/
theorem summable_subtree {s : ℝ} (hs : Real.log 2 / Real.log (5 / 2) < s) :
    Summable (subtreeTerm s) := by
  have hlog : 0 < Real.log (5 / 2 : ℝ) := Real.log_pos (by norm_num)
  have hspos : 0 < s := by
    have : 0 < Real.log 2 / Real.log (5 / 2 : ℝ) :=
      div_pos (Real.log_pos (by norm_num)) hlog
    linarith
  -- the geometric ratio
  set r : ℝ := 2 * (5 / 2 : ℝ) ^ (-s) with hr
  have hr0 : 0 < r := by
    have : (0 : ℝ) < (5 / 2 : ℝ) ^ (-s) := Real.rpow_pos_of_pos (by norm_num) _
    simpa [hr] using by positivity
  have hr1 : r < 1 := by
    have hlt : Real.log 2 < s * Real.log (5 / 2 : ℝ) := by
      rw [div_lt_iff₀ hlog] at hs
      linarith
    have hexp : (5 / 2 : ℝ) ^ (-s) < 2⁻¹ := by
      rw [Real.rpow_def_of_pos (by norm_num : (0:ℝ) < 5/2)]
      have : Real.exp (Real.log (5 / 2 : ℝ) * -s) < Real.exp (-Real.log 2) := by
        apply Real.exp_lt_exp.2
        nlinarith
      calc Real.exp (Real.log (5 / 2 : ℝ) * -s) < Real.exp (-Real.log 2) := this
        _ = 2⁻¹ := by
            rw [Real.exp_neg, Real.exp_log (by norm_num : (0:ℝ) < 2)]
    rw [hr]
    linarith
  rw [summable_sigma_of_nonneg (subtreeTerm_nonneg s)]
  refine ⟨fun d => Summable.of_finite, ?_⟩
  -- bound the fibre sums by a geometric series
  have hbound : ∀ d : ℕ, ∑' y : Fin d → Bool, subtreeTerm s ⟨d, y⟩
      ≤ (5 : ℝ) ^ (-s) * r ^ d := by
    intro d
    have hterm : ∀ y : Fin d → Bool,
        subtreeTerm s ⟨d, y⟩ ≤ (5 : ℝ) ^ (-s) * ((5 / 2 : ℝ) ^ (-s)) ^ d := by
      intro y
      have hlen : (List.ofFn y).length = d := List.length_ofFn
      have hlow : 5 * (5 / 2 : ℝ) ^ d ≤ (hyp (blocks (List.ofFn y)) : ℝ) := by
        have := hyp_blocks_lower (List.ofFn y)
        rwa [hlen] at this
      have hpos5 : (0 : ℝ) < 5 * (5 / 2 : ℝ) ^ d := by positivity
      have := Real.rpow_le_rpow_of_nonpos hpos5 hlow (neg_nonpos.2 hspos.le)
      refine this.trans_eq ?_
      rw [Real.mul_rpow (by norm_num) (by positivity), ← Real.rpow_natCast (5/2 : ℝ) d,
        ← Real.rpow_natCast ((5/2 : ℝ) ^ (-s)) d, ← Real.rpow_mul (by norm_num),
        ← Real.rpow_mul (by norm_num)]
      ring_nf
    calc ∑' y : Fin d → Bool, subtreeTerm s ⟨d, y⟩
        = ∑ y : Fin d → Bool, subtreeTerm s ⟨d, y⟩ := tsum_fintype _
      _ ≤ ∑ _y : Fin d → Bool, (5 : ℝ) ^ (-s) * ((5 / 2 : ℝ) ^ (-s)) ^ d :=
          Finset.sum_le_sum (fun y _ => hterm y)
      _ = (2 ^ d : ℕ) * ((5 : ℝ) ^ (-s) * ((5 / 2 : ℝ) ^ (-s)) ^ d) := by
          simp [Finset.sum_const, Finset.card_univ]
      _ = (5 : ℝ) ^ (-s) * r ^ d := by
          rw [hr, mul_pow]
          push_cast
          ring
  refine Summable.of_nonneg_of_le (fun d => tsum_nonneg (fun y => subtreeTerm_nonneg s _))
    hbound ?_
  exact (summable_geometric_of_lt_one hr0.le hr1).mul_left _

/-- **Divergence of the hyperbolic subtree zeta** below `log 2 / log((3+2√2)²)`. -/
theorem not_summable_subtree {s : ℝ} (hs0 : 0 < s)
    (hs : s < Real.log 2 / Real.log ((3 + 2 * Real.sqrt 2) ^ 2)) :
    ¬ Summable (subtreeTerm s) := by
  have h2 : (1 : ℝ) ≤ Real.sqrt 2 := one_le_sqrt_two
  set A : ℝ := (3 + 2 * Real.sqrt 2) ^ 2 with hA
  have hA1 : (1 : ℝ) < A := by
    rw [hA]; nlinarith
  have hApos : (0 : ℝ) < A := by linarith
  have hlogA : 0 < Real.log A := Real.log_pos hA1
  set q : ℝ := 2 * A ^ (-s) with hq
  have hq1 : 1 < q := by
    have hlt : s * Real.log A < Real.log 2 := by
      rw [lt_div_iff₀ hlogA] at hs
      linarith
    have hexp : 2⁻¹ < A ^ (-s) := by
      rw [Real.rpow_def_of_pos hApos]
      have : Real.exp (-Real.log 2) < Real.exp (Real.log A * -s) := by
        apply Real.exp_lt_exp.2
        nlinarith
      calc (2 : ℝ)⁻¹ = Real.exp (-Real.log 2) := by
            rw [Real.exp_neg, Real.exp_log (by norm_num : (0:ℝ) < 2)]
        _ < Real.exp (Real.log A * -s) := this
    rw [hq]
    linarith
  intro hsum
  -- the fibre sums must tend to zero
  have hfib := ((summable_sigma_of_nonneg (subtreeTerm_nonneg s)).1 hsum).2
  have hzero := hfib.tendsto_atTop_zero
  -- but they are at least `5^{-s} q^d → ∞`
  have hlow : ∀ d : ℕ, (5 : ℝ) ^ (-s) * q ^ d
      ≤ ∑' y : Fin d → Bool, subtreeTerm s ⟨d, y⟩ := by
    intro d
    have hterm : ∀ y : Fin d → Bool,
        (5 : ℝ) ^ (-s) * (A ^ (-s)) ^ d ≤ subtreeTerm s ⟨d, y⟩ := by
      intro y
      have hlen : (List.ofFn y).length = d := List.length_ofFn
      have hup : (hyp (blocks (List.ofFn y)) : ℝ) ≤ 5 * A ^ d := by
        have := hyp_blocks_upper (List.ofFn y)
        rw [hlen] at this
        calc (hyp (blocks (List.ofFn y)) : ℝ)
            ≤ 5 * (3 + 2 * Real.sqrt 2) ^ (2 * d) := this
          _ = 5 * A ^ d := by rw [hA, ← pow_mul, mul_comm 2 d]
      have hpos := hyp_pos (blocks (List.ofFn y))
      have := Real.rpow_le_rpow_of_nonpos hpos hup (neg_nonpos.2 hs0.le)
      refine le_trans (le_of_eq ?_) this
      rw [Real.mul_rpow (by norm_num) (by positivity), ← Real.rpow_natCast A d,
        ← Real.rpow_natCast (A ^ (-s)) d, ← Real.rpow_mul hApos.le,
        ← Real.rpow_mul hApos.le]
      ring_nf
    calc (5 : ℝ) ^ (-s) * q ^ d
        = (2 ^ d : ℕ) * ((5 : ℝ) ^ (-s) * (A ^ (-s)) ^ d) := by
          rw [hq, mul_pow]
          push_cast
          ring
      _ = ∑ _y : Fin d → Bool, (5 : ℝ) ^ (-s) * (A ^ (-s)) ^ d := by
          simp [Finset.sum_const, Finset.card_univ]
      _ ≤ ∑ y : Fin d → Bool, subtreeTerm s ⟨d, y⟩ :=
          Finset.sum_le_sum (fun y _ => hterm y)
      _ = ∑' y : Fin d → Bool, subtreeTerm s ⟨d, y⟩ := (tsum_fintype _).symm
  have hdiv : Filter.Tendsto (fun d : ℕ => (5 : ℝ) ^ (-s) * q ^ d) Filter.atTop Filter.atTop :=
    Filter.Tendsto.const_mul_atTop (Real.rpow_pos_of_pos (by norm_num) _)
      (tendsto_pow_atTop_atTop_of_one_lt hq1)
  have hbig : Filter.Tendsto (fun d : ℕ => ∑' y : Fin d → Bool, subtreeTerm s ⟨d, y⟩)
      Filter.atTop Filter.atTop :=
    Filter.tendsto_atTop_mono hlow hdiv
  exact not_tendsto_nhds_of_tendsto_atTop hbig 0 hzero

/-- **The hyperbolic subtree converges at `s = 1`**, where the full tree zeta diverges:
removing the parabolic directions lowers the abscissa below `1`. -/
theorem subtree_summable_at_one : Summable (subtreeTerm 1) := by
  refine summable_subtree ?_
  have hlog : 0 < Real.log (5 / 2 : ℝ) := Real.log_pos (by norm_num)
  rw [div_lt_one hlog]
  exact Real.log_lt_log (by norm_num) (by norm_num)

end BerggrenZeta