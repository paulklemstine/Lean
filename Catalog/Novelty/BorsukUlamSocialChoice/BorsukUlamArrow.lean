import Mathlib

/-!
# Borsuk–Ulam and Social Choice: the topological kernel and a contrarian disproof

This file investigates the conjecture that **Arrow's impossibility theorem is a
corollary of the Borsuk–Ulam theorem**, and that consequently *"any social choice
function on `n` alternatives is either discontinuous or dictatorial."*

We treat the claim in **contrarian** mode: we isolate the genuine topological
kernel that *is* true, and we **disprove** the over-strong conjecture.

## Part I — The topological kernel (positive results)

The honest mathematical content of the "preference sphere" picture, in the
lowest dimension, is the **one-dimensional Borsuk–Ulam theorem**: a continuous
`2π`-periodic function `f : ℝ → ℝ` (a continuous function on the circle
`S¹ = ℝ / 2πℤ`, i.e. `f : S¹ → ℝ¹`) must send some pair of antipodal points
`x`, `x + π` to the same value.

* `borsuk_ulam_1d` : `∃ x, f x = f (x + π)`.

Its social-choice reading is the genuine kernel of the description's
"contradiction with Pareto efficiency": one cannot continuously and *strictly*
prefer every profile over its antipode.

* `no_strict_antipodal_preference` : `¬ ∀ x, f (x + π) < f x`.
* `no_strict_antipodal_preference'` : `¬ ∀ x, f x < f (x + π)`.

## Part II — The contrarian disproof

The strong conjecture *"continuous ⟹ dictatorial"* is **false** once the space of
preferences is **contractible** (e.g. the real line), rather than a sphere. The
topological obstruction of Borsuk–Ulam/Chichilnisky genuinely requires the
non-contractible sphere topology; it says nothing about aggregation on a convex
domain. We exhibit an explicit **averaging** aggregator on `n ≥ 2` agents that is
simultaneously

* continuous (`avg_continuous`),
* unanimous / Pareto (`avg_unanimity`),
* anonymous, hence symmetric (`avg_anonymous`),
* **non-dictatorial** (`avg_not_dictatorial`),

packaged as `continuous_nondictatorial_aggregator_exists`. This directly refutes
the conjecture that every continuous aggregation rule is dictatorial.
-/

namespace BorsukUlamArrow

open scoped Real
open Set

/-! ## Part I: one-dimensional Borsuk–Ulam and its social-choice reading -/

/-- **One-dimensional Borsuk–Ulam theorem.** A continuous `2π`-periodic function
`f : ℝ → ℝ` — that is, a continuous map from the circle `S¹` to `ℝ¹` — sends some
pair of antipodal points `x` and `x + π` to the same value. -/
theorem borsuk_ulam_1d (f : ℝ → ℝ) (hf : Continuous f)
    (hper : ∀ x, f (x + 2 * Real.pi) = f x) :
    ∃ x, f x = f (x + Real.pi) := by
  -- Define `g x = f x - f (x + π)`; it is odd under the half-turn: `g (x+π) = -g x`.
  set g : ℝ → ℝ := fun x => f x - f (x + Real.pi);
  -- Hence `g 0 = -g π`, and the IVT on `[0, π]` gives a zero of `g`.
  have h_ivt : ∃ c ∈ Set.Icc 0 Real.pi, g c = 0 := by
    have h_cont : ContinuousOn g (Set.Icc 0 Real.pi) := by
      exact hf.continuousOn.sub ( hf.comp_continuousOn ( continuousOn_id.add continuousOn_const ) )
    have h_ivt : ∃ c ∈ Set.Icc 0 Real.pi, g c = 0 := by
      have h_sign_change : g 0 = -g Real.pi := by
        grind
      have := h_cont.image_Icc Real.pi_pos.le;
      exact this.symm.subset ( Set.mem_Icc.mpr ⟨ by linarith [ Set.mem_Icc.mp ( this ▸ Set.mem_image_of_mem g ( Set.left_mem_Icc.mpr Real.pi_pos.le ) ), Set.mem_Icc.mp ( this ▸ Set.mem_image_of_mem g ( Set.right_mem_Icc.mpr Real.pi_pos.le ) ) ], by linarith [ Set.mem_Icc.mp ( this ▸ Set.mem_image_of_mem g ( Set.left_mem_Icc.mpr Real.pi_pos.le ) ), Set.mem_Icc.mp ( this ▸ Set.mem_image_of_mem g ( Set.right_mem_Icc.mpr Real.pi_pos.le ) ) ] ⟩ );
    exact h_ivt;
  exact h_ivt.imp fun x hx => sub_eq_zero.mp hx.2

/-- The genuine kernel of the "contradiction with Pareto efficiency": a continuous
periodic social-preference score `f` cannot *strictly* prefer every profile `x`
over its antipode `x + π`. -/
theorem no_strict_antipodal_preference (f : ℝ → ℝ) (hf : Continuous f)
    (hper : ∀ x, f (x + 2 * Real.pi) = f x) :
    ¬ (∀ x, f (x + Real.pi) < f x) := by
  exact fun h => by obtain ⟨ x, hx ⟩ := borsuk_ulam_1d f hf hper; linarith [ h x ]

/-- Symmetric form: `f` also cannot strictly prefer every antipode over the
original profile. -/
theorem no_strict_antipodal_preference' (f : ℝ → ℝ) (hf : Continuous f)
    (hper : ∀ x, f (x + 2 * Real.pi) = f x) :
    ¬ (∀ x, f x < f (x + Real.pi)) := by
  intro h
  obtain ⟨x, hx⟩ := borsuk_ulam_1d f hf hper
  linarith [h x]

/-! ## Part II: contrarian disproof of "continuous ⟹ dictatorial"

We model the space of individual preferences as the real line `ℝ` (a contractible,
convex domain: e.g. positions on a one-dimensional political spectrum). A social
choice / aggregation rule for `n` agents is a map `(Fin n → ℝ) → ℝ`. -/

/-- The averaging aggregator: the social outcome is the mean of the `n` individual
positions. -/
noncomputable def avg (n : ℕ) (p : Fin n → ℝ) : ℝ := (∑ i, p i) / n

/-- **Unanimity (Pareto).** If every agent submits the same position `c`, the
averaging rule returns `c`. -/
theorem avg_unanimity (n : ℕ) (hn : 0 < n) (c : ℝ) :
    avg n (fun _ => c) = c := by
  unfold avg; norm_num [ mul_div_cancel₀, hn.ne' ]

/-- **Anonymity.** The averaging rule is invariant under relabelling the agents,
so it treats all agents symmetrically. -/
theorem avg_anonymous (n : ℕ) (p : Fin n → ℝ) (σ : Equiv.Perm (Fin n)) :
    avg n (p ∘ σ) = avg n p := by
  convert congr_arg ( fun x : ℝ => x / n ) ( Equiv.sum_comp σ p ) using 1

/-- **Continuity.** The averaging rule is continuous on the (finite-dimensional)
profile space. -/
theorem avg_continuous (n : ℕ) : Continuous (avg n) := by
  unfold avg
  fun_prop

/-- **Monotonicity (a strong Pareto axiom).** If every agent's position weakly
increases, the social outcome weakly increases. The averaging rule respects the
coordinatewise order, so it is Pareto-monotone. -/
theorem avg_monotone (n : ℕ) {p q : Fin n → ℝ} (h : ∀ i, p i ≤ q i) :
    avg n p ≤ avg n q := by
  unfold avg
  gcongr with i
  exact h i

/-- **Translation invariance.** Shifting every agent's position by a common
constant `c` shifts the social outcome by `c`. This is a natural neutrality
axiom, again satisfied by the mean. -/
theorem avg_translation_invariant (n : ℕ) (hn : 0 < n) (p : Fin n → ℝ) (c : ℝ) :
    avg n (fun i => p i + c) = avg n p + c := by
  have hn' : (n : ℝ) ≠ 0 := by exact_mod_cast hn.ne'
  unfold avg
  rw [Finset.sum_add_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul]
  field_simp

/-- **Non-dictatorship.** For `n ≥ 2` agents there is no agent `i` whose position
always coincides with the social outcome. -/
theorem avg_not_dictatorial (n : ℕ) (hn : 2 ≤ n) :
    ¬ ∃ i : Fin n, ∀ p : Fin n → ℝ, avg n p = p i := by
  simp +zetaDelta at *;
  intro i
  use fun j => if j = i then 0 else 1;
  unfold avg; norm_num [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq' ]
  omega

/-- **Contrarian disproof.** For every `n ≥ 2` there exists an aggregation rule
that is simultaneously continuous, unanimous (Pareto), anonymous, and
non-dictatorial. Hence the conjecture *"any social choice function on `n`
alternatives is either discontinuous or dictatorial"* is **false**: the
Borsuk–Ulam obstruction requires the non-contractible sphere topology and does
not apply to aggregation on a contractible preference space. -/
theorem continuous_nondictatorial_aggregator_exists (n : ℕ) (hn : 2 ≤ n) :
    ∃ F : (Fin n → ℝ) → ℝ,
      Continuous F ∧
      (∀ c, F (fun _ => c) = c) ∧
      (∀ (p : Fin n → ℝ) (σ : Equiv.Perm (Fin n)), F (p ∘ σ) = F p) ∧
      (¬ ∃ i : Fin n, ∀ p, F p = p i) := by
  refine' ⟨ fun p => ( ∑ i, p i ) / n, _, _, _, _ ⟩
  · fun_prop
  · simp +decide [ show n ≠ 0 by linarith ]
  · exact fun p σ => by simp +decide [ Equiv.sum_comp σ p ]
  · convert avg_not_dictatorial n hn using 1

end BorsukUlamArrow