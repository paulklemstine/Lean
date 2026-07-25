/-
# The Unreasonable Effectiveness of Wrong Theories — Deepening

A *deepening* of the meta-theory of wrong theories, formalized via inner-product
geometry on **theory-space**.

## Setup (recalled)

The space of physical **theories** is a real inner-product space `E`.  A
distinguished `truth : E` describes nature exactly; a *theory* `T : E` is any
point.  Its **wrongness** is the distance `wrongness truth T = ‖T - truth‖`.  A
**phenomenon** is a measurement direction `u : E`; a theory's prediction for `u`
is `⟪T, u⟫`, and its **prediction error** is `predErr truth T u = |⟪T - truth, u⟫|`.

This file re-develops the two definitions from scratch (so it is self-contained)
and then proves genuinely new, deeper results.

## New results

Phenomenological convergence:

* `predErr_le_wrongness` — every prediction error is controlled by the global
  wrongness via Cauchy–Schwarz: `predErr truth T u ≤ wrongness truth T * ‖u‖`.
* `predErr_partialTheory_tendsto_zero` — if the perturbative corrections `c` sum
  to `truth - T₀`, then for **every fixed phenomenon** the prediction error of the
  corrected theories tends to `0`.

Quantitative meta-theorem (single rival):

* `wrong_theory_beats_rival_quant` — for a wrong theory `A` whose error is not
  parallel to a rival `B`'s error, the *orthogonal component* of `B`'s error
  against `A`'s error is an **explicit** phenomenon on which `A` is exactly right
  while `B` errs by exactly `‖orthogonal component‖²`.

The flagship generalization (arbitrarily many rivals at once):

* `exists_inner_ne_zero_list` — a linear-algebra core lemma: for any finite list
  of nonzero vectors there is a single vector pairing nontrivially with all of
  them, lying in their span (dually: orthogonal to everything they annihilate).
* `wrong_theory_beats_finite_rivals` — **the deepened meta-theorem.** Given *any
  finite family* of rival theories, none of whose errors is parallel to `A`'s
  error, there is a *single* phenomenon on which the wrong theory `A` is exactly
  right while **every** rival simultaneously errs.

Everything is proved from scratch over an arbitrary real inner-product space.
-/
import Mathlib

open scoped RealInnerProductSpace Topology

namespace WrongTheoriesDeepening

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- The **wrongness** of a theory `T` relative to `truth`: its distance in
theory-space. -/
def wrongness (truth T : E) : ℝ := ‖T - truth‖

omit [InnerProductSpace ℝ E] in
theorem wrongness_nonneg (truth T : E) : 0 ≤ wrongness truth T := norm_nonneg _

/-- The **prediction error** a theory `T` makes on the phenomenon `u`. -/
noncomputable def predErr (truth T u : E) : ℝ := |⟪T - truth, u⟫|

theorem predErr_nonneg (truth T u : E) : 0 ≤ predErr truth T u := abs_nonneg _

/-- The `n`-th perturbatively corrected theory, `T₀ + ∑_{i<n} cᵢ`. -/
def partialTheory (T₀ : E) (c : ℕ → E) (n : ℕ) : E :=
  T₀ + ∑ i ∈ Finset.range n, c i

/-! ## Phenomenological convergence -/

/-
**Every prediction error is dominated by the global wrongness** (Cauchy–
Schwarz): a theory that is close to the truth in theory-space cannot make a large
prediction error on any bounded phenomenon.
-/
theorem predErr_le_wrongness (truth T u : E) :
    predErr truth T u ≤ wrongness truth T * ‖u‖ := by
  convert abs_real_inner_le_norm ( T - truth ) u using 1

/-
**Perturbative convergence at the level of predictions.**  If the corrections
`c` sum to the gap `truth - T₀`, then for every fixed phenomenon `u` the
prediction error of the corrected theories tends to `0`.
-/
theorem predErr_partialTheory_tendsto_zero (truth T₀ : E) (c : ℕ → E) (u : E)
    (hc : HasSum c (truth - T₀)) :
    Filter.Tendsto (fun n => predErr truth (partialTheory T₀ c n) u)
      Filter.atTop (𝓝 0) := by
  -- By the squeeze theorem, it suffices to show that the upper bound tends to zero.
  suffices h_upper_bound : Filter.Tendsto (fun n => wrongness truth (partialTheory T₀ c n) * ‖u‖) Filter.atTop (nhds 0) by
    exact squeeze_zero ( fun n => predErr_nonneg _ _ _ ) ( fun n => predErr_le_wrongness _ _ _ ) h_upper_bound;
  convert Filter.Tendsto.norm ( hc.tendsto_sum_nat.const_add T₀ |> Filter.Tendsto.sub_const <| truth ) |> Filter.Tendsto.mul_const ‖u‖ using 2 ; norm_num

/-! ## Quantitative meta-theorem: a wrong theory beats a single rival -/

/-
**The Unreasonable Effectiveness of Wrong Theories (quantitative, single
rival).**  Let `A` be our wrong theory and `B` a rival, with `A`'s error not
parallel to `B`'s error.  Write `a = A - truth`, `b = B - truth`, and let
`q = b - (⟪b,a⟫/⟪a,a⟫) • a` be the component of `B`'s error orthogonal to `A`'s
error.  Then `q` is a phenomenon on which `A` is *exactly right*
(`predErr truth A q = 0`) while `B` errs by exactly `‖q‖²`, which is positive.
Thus the wrong theory strictly out-predicts its rival, with an explicit gap.
-/
theorem wrong_theory_beats_rival_quant (truth A B : E) (hA : A ≠ truth)
    (hpar : ∀ r : ℝ, B - truth ≠ r • (A - truth)) :
    predErr truth A
        ((B - truth) - (⟪B - truth, A - truth⟫ / ⟪A - truth, A - truth⟫) • (A - truth)) = 0 ∧
      predErr truth B
        ((B - truth) - (⟪B - truth, A - truth⟫ / ⟪A - truth, A - truth⟫) • (A - truth)) =
        ‖(B - truth) - (⟪B - truth, A - truth⟫ / ⟪A - truth, A - truth⟫) • (A - truth)‖ ^ 2 ∧
      0 < predErr truth B
        ((B - truth) - (⟪B - truth, A - truth⟫ / ⟪A - truth, A - truth⟫) • (A - truth)) := by
  refine' ⟨ _, _, _ ⟩;
  · simp +decide [ predErr, inner_sub_right, inner_smul_right ];
    rw [ div_mul_cancel₀ _ ( pow_ne_zero 2 ( norm_ne_zero_iff.mpr ( sub_ne_zero.mpr hA ) ) ) ] ; simp +decide [ real_inner_comm, inner_sub_left ] ; ring;
  · convert abs_of_nonneg ?_ using 1;
    · simp +decide [ inner_sub_left, inner_sub_right, inner_smul_right ];
      rw [ @norm_sub_sq ℝ ];
      simp +decide [ norm_smul, inner_smul_right ];
      simp +decide [ inner_sub_left, inner_sub_right, div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm, sq, sub_eq_zero, hA ];
      grind;
    · infer_instance;
    · rw [ inner_sub_right, inner_smul_right ];
      rw [ div_mul_eq_mul_div, sub_nonneg, div_le_iff₀ ];
      · simpa only [ real_inner_self_eq_norm_sq ] using by nlinarith [ abs_le.mp ( abs_real_inner_le_norm ( B - truth ) ( A - truth ) ) ] ;
      · exact by rw [ real_inner_self_eq_norm_sq ] ; exact sq_pos_of_pos ( norm_pos_iff.mpr ( sub_ne_zero.mpr hA ) ) ;
  · refine' abs_pos.mpr ( show ⟪B - truth, B - truth - ( ⟪B - truth, A - truth⟫ / ⟪A - truth, A - truth⟫ ) • ( A - truth )⟫ ≠ 0 from _ );
    contrapose! hpar;
    -- By simplifying, we can see that this implies $B - truth$ is a scalar multiple of $A - truth$.
    have h_scalar : ‖B - truth - (⟪B - truth, A - truth⟫ / ‖A - truth‖^2) • (A - truth)‖^2 = 0 := by
      convert hpar using 1;
      rw [ @norm_sub_sq ℝ ] ; simp +decide [ inner_smul_right, inner_sub_right ] ;
      rw [ norm_smul, mul_pow, norm_sub_rev ] ; norm_num ;
      grind;
    exact ⟨ ⟪B - truth, A - truth⟫ / ‖A - truth‖ ^ 2, sub_eq_zero.mp ( norm_eq_zero.mp ( sq_eq_zero_iff.mp h_scalar ) ) ⟩

/-! ## The flagship generalization: beating arbitrarily many rivals at once -/

/-
**Core linear-algebra lemma.**  For any finite list `L` of nonzero vectors in
a real inner-product space there is a single vector `u` pairing nontrivially with
every element of `L`, and lying in their span in the dual sense: `u` is orthogonal
to every vector annihilated by all of `L`.

The proof is by induction on `L`: at each step we adjust the previous witness by a
small multiple of the new vector, choosing the scalar to avoid the finitely many
values that would make some pairing vanish.
-/
theorem exists_inner_ne_zero_list (L : List E) (hL : ∀ q ∈ L, q ≠ 0) :
    ∃ u : E, (∀ q ∈ L, ⟪q, u⟫ ≠ (0 : ℝ)) ∧
      (∀ v : E, (∀ q ∈ L, ⟪q, v⟫ = (0 : ℝ)) → ⟪v, u⟫ = (0 : ℝ)) := by
  induction' L using List.reverseRecOn with w L ih;
  · exact ⟨ 0, by simp +decide ⟩;
  · simp +zetaDelta at *;
    obtain ⟨ u, hu₁, hu₂ ⟩ := ih fun q hq => hL q ( Or.inl hq );
    -- Choose $t$ such that $u + t \cdot L$ is not orthogonal to any element in $w$.
    obtain ⟨ t, ht ⟩ : ∃ t : ℝ, (∀ q ∈ w, ⟪q, u + t • L⟫ ≠ 0) ∧ ⟪L, u + t • L⟫ ≠ 0 := by
      -- Choose $t$ such that $u + t \cdot L$ is not orthogonal to any element in $w$. This is possible because $w$ is finite and $L$ is nonzero.
      have h_choose_t : Set.Finite {t : ℝ | ∃ q ∈ w, ⟪q, u + t • L⟫ = 0} := by
        have h_choose_t : ∀ q ∈ w, Set.Finite {t : ℝ | ⟪q, u + t • L⟫ = 0} := by
          intro q hq
          by_cases hqL : ⟪q, L⟫ = 0;
          · simp_all +decide [ inner_add_right, inner_smul_right ];
          · simp +decide [ inner_add_right, inner_smul_right ];
            exact Set.Finite.subset ( Set.finite_singleton ( -⟪q, u⟫ / ⟪q, L⟫ ) ) fun t ht => eq_div_of_mul_eq hqL <| by linarith [ ht.symm ] ;
        exact Set.Finite.subset ( Set.Finite.biUnion ( List.finite_toSet w ) h_choose_t ) fun x hx => by aesop;
      have h_choose_t : Set.Finite {t : ℝ | ⟪L, u + t • L⟫ = 0} := by
        simp +decide [ inner_add_right, inner_smul_right ];
        exact Set.Finite.subset ( Set.finite_singleton ( -⟪L, u⟫ / ‖L‖ ^ 2 ) ) fun t ht => eq_div_of_mul_eq ( pow_ne_zero 2 ( norm_ne_zero_iff.mpr ( hL L ( Or.inr rfl ) ) ) ) ( by linarith [ ht.symm ] );
      exact Set.Infinite.nonempty ( Set.Infinite.diff ( Set.infinite_univ ) ( Set.Finite.union ‹Set.Finite { t : ℝ | ∃ q ∈ w, ⟪q, u + t • L⟫ = 0 } › ‹Set.Finite { t : ℝ | ⟪L, u + t • L⟫ = 0 } › ) ) |> fun ⟨ t, ht ⟩ => ⟨ t, fun q hq => by aesop, by aesop ⟩;
    refine' ⟨ u + t • L, _, _ ⟩ <;> simp_all +decide [ inner_add_right, inner_smul_right ];
    · rintro q ( hq | rfl ) <;> simp_all +decide;
    · intro v hv; specialize hv L; simp_all +decide [ real_inner_comm ] ;

/-
**The Unreasonable Effectiveness of Wrong Theories (finite rivals).**

Let `A` be our wrong theory (`A ≠ truth`) and let `Bs` be *any finite family* of
rival theories, none of whose errors is parallel to `A`'s error.  Then there is a
*single* phenomenon `u` on which `A` is exactly right while **every** rival in
`Bs` simultaneously makes a nonzero prediction error.  The wrong theory `A` beats
the entire field of rivals at once.
-/
theorem wrong_theory_beats_finite_rivals (truth A : E) (Bs : List E)
    (hA : A ≠ truth)
    (hpar : ∀ B ∈ Bs, ∀ r : ℝ, B - truth ≠ r • (A - truth)) :
    ∃ u : E, predErr truth A u = 0 ∧ ∀ B ∈ Bs, 0 < predErr truth B u := by
  -- Set a = A - truth and define L := List.map (fun B => (B - truth) - (⟪B - truth, a⟫ / ⟪a, a⟫) • a) Bs.
  set a : E := A - truth
  set L := Bs.map (fun B => (B - truth) - (⟪B - truth, a⟫ / ⟪a, a⟫) • a) with hLdef;
  obtain ⟨ u, hu ⟩ := exists_inner_ne_zero_list L (by
  grind +suggestions);
  refine' ⟨ u, _, _ ⟩;
  · refine' abs_eq_zero.mpr ( hu.2 a _ );
    simp +zetaDelta at *;
    simp +decide [ inner_sub_left, inner_smul_left, div_mul_cancel₀ _ ( pow_ne_zero 2 ( norm_ne_zero_iff.mpr ( sub_ne_zero.mpr hA ) ) ) ];
  · intro B hB
    have hq : ⟪B - truth, u⟫ = ⟪(B - truth) - (⟪B - truth, a⟫ / ⟪a, a⟫) • a, u⟫ := by
      have hq : ⟪a, u⟫ = 0 := by
        apply hu.right;
        simp +zetaDelta at *;
        simp +decide [ inner_sub_left, inner_smul_left, sub_ne_zero.mpr hA ];
      simp +decide [ inner_sub_left, inner_smul_left, hq ];
    exact abs_pos.mpr ( hu.1 _ ( List.mem_map.mpr ⟨ B, hB, rfl ⟩ ) |> fun h => hq.symm ▸ h )

end WrongTheoriesDeepening