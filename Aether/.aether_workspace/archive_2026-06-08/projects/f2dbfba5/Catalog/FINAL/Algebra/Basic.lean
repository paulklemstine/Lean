/-
# Freivalds' Algorithm: Finite-Field Hyperplane Counting Engine

This file formalizes the structural core of Freivalds' randomized matrix verification
algorithm as a theorem about kernel density of nonzero linear maps over finite fields.

## Main results

* `card_mulVec_eq_zero_le`: If `M` is a nonzero matrix over `ZMod q` (q prime),
  then `|{r | M.mulVec r = 0}| ≤ q^(p-1)`.
* `freivalds_soundness_card`: The cardinal form of Freivalds' soundness bound.
* `freivalds_soundness_prob`: The probability form: acceptance probability ≤ 1/q.

## Proof architecture

We use Strategy A (row-witness + hyperplane counting):
1. Extract a nonzero row from a nonzero matrix.
2. Show the kernel of `mulVec` injects into the kernel of `dotProduct` with that row.
3. Count solutions to a single nontrivial linear equation: exactly `q^(p-1)`.
4. Derive the cardinality and probability bounds.

The hyperplane counting uses a fiber-counting argument: a nonzero linear functional
on `(Fin p → ZMod q)` is surjective onto `ZMod q`, and all fibers have equal
cardinality by the coset structure, giving `q^p / q = q^(p-1)` per fiber.
-/

import Mathlib

open Matrix Finset Fintype BigOperators

variable {q : ℕ} [hq : Fact q.Prime]

/-
A nonzero function `Fin p → ZMod q` has some nonzero coordinate.
-/
theorem exists_ne_zero_of_ne_zero_vec {p : ℕ}
    {w : Fin p → ZMod q} (hw : w ≠ 0) :
    ∃ j : Fin p, w j ≠ 0 := by
  exact Function.ne_iff.mp hw

/-
A nonzero matrix has a nonzero row.
-/
theorem exists_nonzero_row_of_matrix_ne_zero {m p : ℕ}
    {M : Matrix (Fin m) (Fin p) (ZMod q)} (hM : M ≠ 0) :
    ∃ i : Fin m, M i ≠ 0 := by
  exact Function.ne_iff.mp hM

/-
`(K - L).mulVec r = 0 ↔ K.mulVec r = L.mulVec r`
-/
theorem eq_mulVec_iff_sub_mulVec_eq_zero {m p : ℕ}
    (K L : Matrix (Fin m) (Fin p) (ZMod q))
    (r : Fin p → ZMod q) :
    K.mulVec r = L.mulVec r ↔ (K - L).mulVec r = 0 := by
  simp +decide [ ← eq_sub_iff_add_eq, sub_eq_zero, Matrix.sub_mulVec ]

/-
The dot product linear functional `r ↦ dotProduct w r` is surjective
    when `w ≠ 0`, over a field.
-/
theorem dotProduct_surjective {p : ℕ}
    (w : Fin p → ZMod q) (hw : w ≠ 0) :
    Function.Surjective (fun r : Fin p → ZMod q => dotProduct w r) := by
  -- Since $w$ is a nonzero vector, there exists some $j$ such that $w_j \neq 0$.
  obtain ⟨j, hj⟩ : ∃ j : Fin p, w j ≠ 0 := by
    exact Function.ne_iff.mp hw;
  intro x;
  exact ⟨ fun i => if i = j then x / w j else 0, by simp +decide [ hj, div_eq_inv_mul, dotProduct ] ⟩

/-
All fibers of the dot product map with a nonzero vector have the same cardinality.
-/
theorem card_fiber_dotProduct_eq {p : ℕ}
    (w : Fin p → ZMod q) (hw : w ≠ 0) (a b : ZMod q) :
    Fintype.card {r : Fin p → ZMod q // dotProduct w r = a} =
    Fintype.card {r : Fin p → ZMod q // dotProduct w r = b} := by
  obtain ⟨ j, hj ⟩ := exists_ne_zero_of_ne_zero_vec hw;
  refine' Fintype.card_congr _;
  refine' ⟨ fun x => ⟨ x.val + Pi.single j ( ( b - a ) * ( w j ) ⁻¹ ), _ ⟩, fun x => ⟨ x.val - Pi.single j ( ( b - a ) * ( w j ) ⁻¹ ), _ ⟩, fun x => _, fun x => _ ⟩ <;> simp_all +decide [ dotProduct_add, dotProduct_sub, dotProduct_smul ];
  · grind;
  · grind

/-
The number of solutions to `dotProduct w r = b` for nonzero `w` is `q^(p-1)`.
-/
theorem card_solutions_dotProduct {p : ℕ}
    (w : Fin p → ZMod q) (hw : w ≠ 0) (b : ZMod q) :
    Fintype.card {r : Fin p → ZMod q // dotProduct w r = b} = q ^ (p - 1) := by
  -- By card_fiber_dotProduct_eq, all fibers of the dotProduct map have the same cardinality. The total cardinality of the domain is q^p (= Fintype.card (Fin p → ZMod q) = card_fun_fin_zmod). The surjectivity (dotProduct_surjective) means there are exactly q fibers (one for each element of ZMod q). Since q * fiber_size = q^p, each fiber has size q^(p-1).
  have card_fiber_dotProduct_eq' : ∀ (a b : ZMod q), Fintype.card {r : Fin p → ZMod q // dotProduct w r = a} = Fintype.card {r : Fin p → ZMod q // dotProduct w r = b} := by
    exact?;
  -- By Fintype.card_sigma, we have $\sum_{b : ZMod q} \text{card} \{r // \text{dotProduct} \, w \, r = b\} = \text{card} (\text{Fin} \, p \to \text{ZMod} \, q) = q^p$.
  have card_sum_fibers : ∑ b : ZMod q, Fintype.card {r : Fin p → ZMod q // dotProduct w r = b} = Fintype.card (Fin p → ZMod q) := by
    simp +decide only [Fintype.card_subtype];
    simp +decide only [card_filter];
    rw [ Finset.sum_comm ] ; simp +decide;
  rcases p with ( _ | p ) <;> simp_all +decide [ pow_succ' ];
  · exact False.elim <| hw <| Subsingleton.elim _ _;
  · rw [ Finset.sum_congr rfl fun _ _ => card_fiber_dotProduct_eq' _ b ] at card_sum_fibers ; simp_all +decide [ Finset.card_univ, pow_succ' ];
    exact card_sum_fibers.resolve_right hq.1.ne_zero

/-
If `M.mulVec r = 0`, then in particular `dotProduct (M i) r = 0` for any row `i`.
-/
omit hq in
theorem mulVec_eq_zero_implies_row_dotProduct_eq_zero {m p : ℕ}
    (M : Matrix (Fin m) (Fin p) (ZMod q))
    (r : Fin p → ZMod q) (hr : M.mulVec r = 0) (i : Fin m) :
    dotProduct (M i) r = 0 := by
  simpa using congr_fun hr i

/-- **Core counting theorem**: A nonzero matrix over `ZMod q` has at most `q^(p-1)`
    vectors in the kernel of `mulVec`. -/
theorem card_mulVec_eq_zero_le {m p : ℕ}
    (M : Matrix (Fin m) (Fin p) (ZMod q))
    (hM : M ≠ 0) :
    Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0} ≤ q ^ (p - 1) := by
  -- Extract a nonzero row
  obtain ⟨i, hi⟩ := exists_nonzero_row_of_matrix_ne_zero hM
  -- The kernel of mulVec injects into the hyperplane defined by row i
  calc Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0}
      ≤ Fintype.card {r : Fin p → ZMod q // dotProduct (M i) r = 0} := by
        apply Fintype.card_le_of_injective
          (fun ⟨r, hr⟩ => ⟨r, mulVec_eq_zero_implies_row_dotProduct_eq_zero M r hr i⟩)
        intro ⟨a, _⟩ ⟨b, _⟩ hab
        exact Subtype.ext (Subtype.mk.inj hab)
    _ = q ^ (p - 1) := card_solutions_dotProduct (M i) hi 0

/-
**Freivalds' soundness (cardinal form)**: If `K ≠ A * B`, then the number of
    random vectors `r` for which `K.mulVec r = (A * B).mulVec r` is at most `q^(p-1)`.
-/
theorem freivalds_soundness_card {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    Fintype.card {r : Fin p → ZMod q // K.mulVec r = (A * B).mulVec r}
      ≤ q ^ (p - 1) := by
  -- Set M = K - A*B. From hne, M ≠ 0. Use eq_mulVec_iff_sub_mulVec_eq_zero to rewrite {r | K.mulVec r = (A*B).mulVec r} as {r | M.mulVec r = 0}.
  set M : Matrix (Fin m) (Fin p) (ZMod q) := K - A * B
  have hM : M ≠ 0 := by
    exact sub_ne_zero_of_ne hne;
  convert card_mulVec_eq_zero_le M hM using 1;
  simp +decide [ M, sub_mulVec ];
  simp +decide only [sub_eq_zero]

/-
The total number of functions `Fin p → ZMod q` is `q^p`.
-/
theorem card_fun_fin_zmod {p : ℕ} :
    Fintype.card (Fin p → ZMod q) = q ^ p := by
  simp +decide [ Fintype.card_pi ]

/-
**Freivalds' soundness (probability form)**: If `K ≠ A * B`, then the probability
    that a uniformly random `r` satisfies `K.mulVec r = (A * B).mulVec r` is at most `1/q`.
-/
theorem freivalds_soundness_prob {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    ((Fintype.card {r : Fin p → ZMod q // K.mulVec r = (A * B).mulVec r} : ℚ) /
      Fintype.card (Fin p → ZMod q))
      ≤ (1 : ℚ) / q := by
  -- By Freivalds' soundness theorem, we know that the number of vectors `r` satisfying `K.mulVec r = (A * B).mulVec r` is at most `q^(p-1)`.
  have h_card : Fintype.card {r : (Fin p) → (ZMod q) // (K.mulVec r) = (A * B).mulVec r} ≤ q ^ (p - 1) := by
    convert freivalds_soundness_card A B K hne using 1;
  rw [ div_le_div_iff₀ ] <;> norm_cast <;> cases p <;> simp_all +decide [ pow_succ' ];
  · exact False.elim <| hne <| by ext i j; fin_cases j;
  · nlinarith [ hq.1.pos ];
  · exact ⟨ hq.1.pos, pow_pos hq.1.pos _ ⟩;
  · exact hq.1.pos;
  · exact hq.1.pos

#check @card_mulVec_eq_zero_le
#check @freivalds_soundness_card
#check @freivalds_soundness_prob