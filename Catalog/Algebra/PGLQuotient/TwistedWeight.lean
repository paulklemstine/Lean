import Algebra.PGLQuotient.HeightThreshold

/-!
# The twisted vertex mass and its row-peeling recursion

To compute the vertex volume of the standard arithmetic quotient of `PGL_d(F_q((t^{-1})))`
in arbitrary rank we enlarge the vertex mass `1/|Aut λ|` to a two-parameter family.

For a vertex `λ` of rank `d` (in the gap model of `Algebra.PGLQuotient.VertexModel`) put

* `sigmaExp λ = ∑_i (λ_0 - λ_i)` — the "top-row defect";
* `firstBlockSize λ = #{ i : λ_i = λ_0 }` — the size of the block of maximal entries;
* `blockProdShift q j λ = ∏_i (1 - q^{-(r_i + j·[λ_i = λ_0])})` — the Levi factor with the
  ranks in the top block shifted by `j`;
* `twWeight q c j λ = (q^{dim End + c·σ + j·m} · blockProdShift q j λ)⁻¹`.

For `c = j = 0` this is exactly the vertex mass: `twWeight q 0 0 = vertexWeight q`
(`twWeight_zero_zero`).

The point of the two extra parameters is that the family is *stable under peeling off the top
row of `λ`*: writing a rank-`(n+2)` vertex as `Fin.cons a λ'` with `a = λ_0 - λ_1 ≥ 0` the gap
between the first row and the rest, one gets (`twWeight_cons_zero`, `twWeight_cons_succ`)

`twWeight q c j (cons 0 λ') = K · twWeight q (c+1) (j+1) λ'`,
`twWeight q c j (cons (a+1) λ') = K · q^{-(n+1)(c+1)(a+1)} · twWeight q (c+1) 0 λ'`,

with `K = (q^{n+2+j}(1 - q^{-(1+j)}))⁻¹`.  This is the recursion which, summed over all
vertices, produces the closed product form of the vertex volume.
-/

namespace PGLQuotient

open Finset

variable {d : ℕ}

/-- The top-row defect `σ(λ) = ∑_i (λ_0 - λ_i)`. -/
def sigmaExp (g : Vertex d) : ℕ := ∑ i ∈ range d, (lam g 0 - lam g i)

/-- The size `m(λ) = #{i : λ_i = λ_0}` of the block of maximal entries. -/
def firstBlockSize (g : Vertex d) : ℕ := ((range d).filter (fun i => lam g i = lam g 0)).card

/-- The Levi factor with the block ranks in the top block shifted by `j`. -/
noncomputable def blockProdShift (q : ℝ) (j : ℕ) (g : Vertex d) : ℝ :=
  ∏ i ∈ range d, (1 - q⁻¹ ^ (blockRank g i + (if lam g i = lam g 0 then j else 0)))

/-- The twisted vertex mass. -/
noncomputable def twWeight (q : ℝ) (c j : ℕ) (g : Vertex d) : ℝ :=
  (q ^ (endDim g + c * sigmaExp g + j * firstBlockSize g) * blockProdShift q j g)⁻¹

section Basic

variable {q : ℝ}

lemma blockProdShift_zero (g : Vertex d) :
    blockProdShift q 0 g = ∏ i ∈ range d, (1 - q⁻¹ ^ blockRank g i) := by
  unfold blockProdShift
  exact Finset.prod_congr rfl (fun i _ => by simp)

/-- For the untwisted parameters the twisted mass is the vertex mass. -/
lemma twWeight_zero_zero (g : Vertex d) : twWeight q 0 0 g = vertexWeight q g := by
  unfold twWeight vertexWeight autOrder
  rw [blockProdShift_zero]
  simp

/-- Every Levi factor `1 - q^{-r}` with `r ≥ 1` is positive. -/
lemma one_sub_inv_pow_pos (hq : 1 < q) {r : ℕ} (hr : 1 ≤ r) : 0 < 1 - q⁻¹ ^ r := by
  have h1 : q⁻¹ ^ r ≤ q⁻¹ ^ 1 :=
    pow_le_pow_of_le_one (le_of_lt (inv_pos.mpr (lt_trans zero_lt_one hq)))
      (le_of_lt (inv_lt_one_of_one_lt hq)) hr
  have h2 : q⁻¹ < 1 := inv_lt_one_of_one_lt hq
  simp only [pow_one] at h1
  linarith

/-- The Levi factors increase with the shift. -/
lemma one_sub_inv_pow_mono (hq : 1 < q) {r s : ℕ} (hrs : r ≤ s) :
    1 - q⁻¹ ^ r ≤ 1 - q⁻¹ ^ s := by
  have h1 : q⁻¹ ^ s ≤ q⁻¹ ^ r :=
    pow_le_pow_of_le_one (le_of_lt (inv_pos.mpr (lt_trans zero_lt_one hq)))
      (le_of_lt (inv_lt_one_of_one_lt hq)) hrs
  linarith

lemma blockProdShift_pos (hq : 1 < q) (j : ℕ) (g : Vertex d) : 0 < blockProdShift q j g :=
  Finset.prod_pos (fun i _ => one_sub_inv_pow_pos hq (by have := one_le_blockRank g i; omega))

lemma twWeight_pos (hq : 1 < q) (c j : ℕ) (g : Vertex d) : 0 < twWeight q c j g := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  exact inv_pos.mpr (mul_pos (pow_pos hq0 _) (blockProdShift_pos hq j g))

/-- Twisting only decreases the mass. -/
lemma twWeight_le_vertexWeight (hq : 1 < q) (c j : ℕ) (g : Vertex d) :
    twWeight q c j g ≤ vertexWeight q g := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hvw : vertexWeight q g = (q ^ endDim g * blockProdShift q 0 g)⁻¹ := by
    rw [blockProdShift_zero]
    rfl
  have h0 : 0 < q ^ endDim g * blockProdShift q 0 g :=
    mul_pos (pow_pos hq0 _) (blockProdShift_pos hq 0 g)
  have hBP : blockProdShift q 0 g ≤ blockProdShift q j g := by
    unfold blockProdShift
    refine Finset.prod_le_prod (fun i _ => ?_) (fun i _ => ?_)
    · exact le_of_lt (one_sub_inv_pow_pos hq
        (by have := one_le_blockRank g i; split_ifs <;> omega))
    · exact one_sub_inv_pow_mono hq (by split_ifs <;> omega)
  have hle : q ^ endDim g * blockProdShift q 0 g
      ≤ q ^ (endDim g + c * sigmaExp g + j * firstBlockSize g) * blockProdShift q j g :=
    mul_le_mul (pow_le_pow_right₀ hq.le (by omega)) hBP
      (le_of_lt (blockProdShift_pos hq 0 g)) (le_of_lt (pow_pos hq0 _))
  rw [hvw]
  exact inv_anti₀ h0 hle

end Basic

section Peeling

variable {n : ℕ}

/-- Prepending a top gap `a` to a rank-`(n+1)` vertex gives a rank-`(n+2)` vertex. -/
def consV (a : ℕ) (g : Vertex (n + 1)) : Vertex (n + 2) := Fin.cons a g

/-- Peeling the first index off a filtered cardinality over a range. -/
lemma card_filter_range_succ (p : ℕ → Prop) [DecidablePred p] (N : ℕ) :
    ((range (N + 1)).filter p).card
      = ((range N).filter (fun i => p (i + 1))).card + (if p 0 then 1 else 0) := by
  rw [Finset.card_filter, Finset.card_filter, Finset.sum_range_succ']

lemma gapAt_consV_zero (a : ℕ) (g : Vertex (n + 1)) : gapAt (consV a g) 0 = a := by
  simp [gapAt, consV]

lemma gapAt_consV_succ (a : ℕ) (g : Vertex (n + 1)) (k : ℕ) :
    gapAt (consV a g) (k + 1) = gapAt g k := by
  unfold gapAt consV
  by_cases hk : k < n
  · rw [dif_pos (show k + 1 < n + 2 - 1 by omega), dif_pos (show k < n + 1 - 1 by omega)]
    rfl
  · rw [dif_neg (show ¬ k + 1 < n + 2 - 1 by omega), dif_neg (show ¬ k < n + 1 - 1 by omega)]

lemma lam_cons_succ (a : ℕ) (g : Vertex (n + 1)) (i : ℕ) :
    lam (consV a g) (i + 1) = lam g i := by
  unfold lam
  rw [Finset.sum_Ico_eq_sum_range, Finset.sum_Ico_eq_sum_range,
    show n + 2 - 1 - (i + 1) = n + 1 - 1 - i by omega]
  refine Finset.sum_congr rfl (fun t _ => ?_)
  rw [show i + 1 + t = (i + t) + 1 by omega, gapAt_consV_succ]

lemma lam_cons_zero (a : ℕ) (g : Vertex (n + 1)) :
    lam (consV a g) 0 = a + lam g 0 := by
  unfold lam
  rw [Finset.sum_Ico_eq_sum_range, Finset.sum_Ico_eq_sum_range]
  simp only [Nat.sub_zero, Nat.zero_add, Nat.add_sub_cancel]
  rw [show n + 2 - 1 = n + 1 from rfl,
    Finset.sum_range_succ' (fun t => gapAt (consV a g) t) n, gapAt_consV_zero,
    Finset.sum_congr rfl (fun t _ => gapAt_consV_succ a g t), Nat.add_comm]

lemma sigmaExp_cons (a : ℕ) (g : Vertex (n + 1)) :
    sigmaExp (consV a g) = (n + 1) * a + sigmaExp g := by
  unfold sigmaExp
  rw [Finset.sum_range_succ' (fun i => lam (consV a g) 0 - lam (consV a g) i) (n + 1)]
  simp only [Nat.sub_self, Nat.add_zero]
  have hterm : ∀ i ∈ range (n + 1),
      lam (consV a g) 0 - lam (consV a g) (i + 1) = a + (lam g 0 - lam g i) := by
    intro i _
    rw [lam_cons_succ, lam_cons_zero]
    have := lam_antitone g (Nat.zero_le i)
    omega
  rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, Finset.sum_const, Finset.card_range,
    smul_eq_mul]

lemma firstBlockSize_cons (a : ℕ) (g : Vertex (n + 1)) :
    firstBlockSize (consV a g)
      = (if a = 0 then firstBlockSize g else 0) + 1 := by
  unfold firstBlockSize
  rw [card_filter_range_succ (fun i => lam (consV a g) i = lam (consV a g) 0) (n + 1), if_pos rfl]
  congr 1
  by_cases ha : a = 0
  · subst ha
    rw [if_pos rfl]
    congr 1
    refine Finset.filter_congr (fun i _ => ?_)
    rw [lam_cons_succ, lam_cons_zero, Nat.zero_add]
  · rw [if_neg ha]
    have : (range (n + 1)).filter (fun i => lam (consV a g) (i + 1) = lam (consV a g) 0) = ∅ := by
      refine Finset.filter_false_of_mem (fun i _ => ?_)
      rw [lam_cons_succ, lam_cons_zero]
      have := lam_antitone g (Nat.zero_le i)
      omega
    rw [this, Finset.card_empty]

/-- The number of rows of `λ'` tied with the top row, seen from the prepended row. -/
lemma sum_tie_cons (a : ℕ) (g : Vertex (n + 1)) :
    ∑ i ∈ range (n + 1), (lam g i + 1 - (a + lam g 0))
      = (if a = 0 then firstBlockSize g else 0) := by
  have hterm : ∀ i ∈ range (n + 1),
      lam g i + 1 - (a + lam g 0) = (if lam g i = a + lam g 0 then 1 else 0) := by
    intro i _
    have := lam_antitone g (Nat.zero_le i)
    by_cases h : lam g i = a + lam g 0
    · rw [if_pos h]; omega
    · rw [if_neg h]; omega
  rw [Finset.sum_congr rfl hterm]
  by_cases ha : a = 0
  · subst ha
    rw [if_pos rfl]
    unfold firstBlockSize
    rw [Finset.card_filter]
    exact Finset.sum_congr rfl (fun i _ => by rw [Nat.zero_add])
  · rw [if_neg ha]
    refine Finset.sum_eq_zero (fun i _ => ?_)
    have := lam_antitone g (Nat.zero_le i)
    rw [if_neg (by omega)]

lemma endDim_cons (a : ℕ) (g : Vertex (n + 1)) :
    endDim (consV a g)
      = endDim g + (n + 2) + (n + 1) * a + sigmaExp g
        + (if a = 0 then firstBlockSize g else 0) := by
  unfold endDim
  have hinner : ∀ i : ℕ, ∑ j ∈ range (n + 2), (lam (consV a g) i + 1 - lam (consV a g) j)
      = (∑ j ∈ range (n + 1), (lam (consV a g) i + 1 - lam g j))
        + (lam (consV a g) i + 1 - (a + lam g 0)) := by
    intro i
    rw [Finset.sum_range_succ' (fun j => lam (consV a g) i + 1 - lam (consV a g) j) (n + 1),
      lam_cons_zero]
    congr 1
    exact Finset.sum_congr rfl (fun j _ => by rw [lam_cons_succ])
  rw [Finset.sum_range_succ'
    (fun i => ∑ j ∈ range (n + 2), (lam (consV a g) i + 1 - lam (consV a g) j)) (n + 1),
    hinner 0, lam_cons_zero]
  have hrest : ∀ i ∈ range (n + 1),
      (∑ j ∈ range (n + 2), (lam (consV a g) (i + 1) + 1 - lam (consV a g) j))
        = (∑ j ∈ range (n + 1), (lam g i + 1 - lam g j))
          + (lam g i + 1 - (a + lam g 0)) := by
    intro i _
    rw [hinner (i + 1), lam_cons_succ]
  rw [Finset.sum_congr rfl hrest, Finset.sum_add_distrib, sum_tie_cons]
  have htop : ∑ j ∈ range (n + 1), (a + lam g 0 + 1 - lam g j)
      = (n + 1) * (a + 1) + sigmaExp g := by
    have hterm : ∀ j ∈ range (n + 1),
        a + lam g 0 + 1 - lam g j = (a + 1) + (lam g 0 - lam g j) := by
      intro j _
      have := lam_antitone g (Nat.zero_le j)
      omega
    rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, Finset.sum_const, Finset.card_range,
      smul_eq_mul]
    rfl
  rw [htop, show a + lam g 0 + 1 - (a + lam g 0) = 1 from by omega]
  ring

lemma blockRank_consV_zero (a : ℕ) (g : Vertex (n + 1)) : blockRank (consV a g) 0 = 1 := by
  unfold blockRank
  simp [Finset.filter_singleton]

lemma blockRank_consV_succ (a : ℕ) (g : Vertex (n + 1)) (i : ℕ) :
    blockRank (consV a g) (i + 1)
      = blockRank g i + (if a = 0 ∧ lam g i = lam g 0 then 1 else 0) := by
  unfold blockRank
  rw [card_filter_range_succ (fun k => lam (consV a g) k = lam (consV a g) (i + 1)) (i + 1)]
  congr 1
  · congr 1
    refine Finset.filter_congr (fun k _ => ?_)
    rw [lam_cons_succ, lam_cons_succ]
  · rw [lam_cons_zero, lam_cons_succ]
    have := lam_antitone g (Nat.zero_le i)
    by_cases ha : a = 0
    · subst ha
      by_cases h : lam g i = lam g 0
      · rw [if_pos (by omega), if_pos ⟨rfl, h⟩]
      · rw [if_neg (by omega), if_neg (by simp [h])]
    · rw [if_neg (by omega), if_neg (by simp [ha])]

lemma blockProdShift_cons (q : ℝ) (j a : ℕ) (g : Vertex (n + 1)) :
    blockProdShift q j (consV a g)
      = (1 - q⁻¹ ^ (1 + j)) *
        (if a = 0 then blockProdShift q (j + 1) g else blockProdShift q 0 g) := by
  unfold blockProdShift
  rw [Finset.prod_range_succ'
    (fun i => 1 - q⁻¹ ^ (blockRank (consV a g) i
      + (if lam (consV a g) i = lam (consV a g) 0 then j else 0))) (n + 1),
    blockRank_consV_zero, if_pos rfl, mul_comm]
  congr 1
  by_cases ha : a = 0
  · subst ha
    rw [if_pos rfl]
    refine Finset.prod_congr rfl (fun i _ => ?_)
    rw [blockRank_consV_succ, lam_cons_succ, lam_cons_zero, Nat.zero_add]
    by_cases h : lam g i = lam g 0
    · rw [if_pos ⟨rfl, h⟩, if_pos h, if_pos h]
      congr 2
      omega
    · rw [if_neg (by simp [h]), if_neg h, if_neg h]
  · rw [if_neg ha]
    refine Finset.prod_congr rfl (fun i _ => ?_)
    rw [blockRank_consV_succ, lam_cons_succ, lam_cons_zero]
    have := lam_antitone g (Nat.zero_le i)
    rw [if_neg (by simp [ha]), if_neg (show ¬ lam g i = a + lam g 0 by omega)]
    simp

variable {q : ℝ}

/-- Peeling a top row with zero gap. -/
lemma twWeight_cons_zero (hq : 1 < q) (c j : ℕ) (g : Vertex (n + 1)) :
    twWeight q c j (consV 0 g)
      = (q ^ (n + 2 + j) * (1 - q⁻¹ ^ (1 + j)))⁻¹ * twWeight q (c + 1) (j + 1) g := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  unfold twWeight
  rw [endDim_cons, sigmaExp_cons, firstBlockSize_cons, blockProdShift_cons]
  simp only [reduceIte]
  rw [show endDim g + (n + 2) + (n + 1) * 0 + sigmaExp g + firstBlockSize g
      + c * ((n + 1) * 0 + sigmaExp g) + j * (firstBlockSize g + 1)
      = (endDim g + (c + 1) * sigmaExp g + (j + 1) * firstBlockSize g) + (n + 2 + j) by ring]
  rw [← mul_inv]
  congr 1
  rw [pow_add]
  ring

/-- Peeling a top row with positive gap. -/
lemma twWeight_cons_succ (hq : 1 < q) (c j a : ℕ) (g : Vertex (n + 1)) :
    twWeight q c j (consV (a + 1) g)
      = (q ^ (n + 2 + j) * (1 - q⁻¹ ^ (1 + j)))⁻¹
        * ((q ^ ((n + 1) * (c + 1))) ^ (a + 1))⁻¹ * twWeight q (c + 1) 0 g := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hane : ¬ (a + 1 = 0) := by omega
  unfold twWeight
  rw [endDim_cons, sigmaExp_cons, firstBlockSize_cons, blockProdShift_cons]
  simp only [if_neg hane]
  rw [show endDim g + (n + 2) + (n + 1) * (a + 1) + sigmaExp g + 0
      + c * ((n + 1) * (a + 1) + sigmaExp g) + j * (0 + 1)
      = (endDim g + (c + 1) * sigmaExp g + 0 * firstBlockSize g)
        + (n + 2 + j) + (n + 1) * (c + 1) * (a + 1) by ring]
  rw [← mul_inv, ← mul_inv]
  congr 1
  rw [pow_add, pow_add, ← pow_mul]
  ring

end Peeling

end PGLQuotient