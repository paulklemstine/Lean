import Mathlib

/-!
# Tropical Reflective Equilibrium: Min-Plus Self-Reference Dynamics

This file formalizes the theory of **tropical reflective operators** over finite state
spaces `Fin n → ℝ`, proving existence, uniqueness, and optimality of fixed points
under separation conditions on the influence matrix.

## Mathematical Setup

We work with a finite state space indexed by `Fin n` for `n ≥ 2`, an influence
matrix `W : Matrix (Fin n) (Fin n) ℝ` encoding min-plus coupling strengths,
and a bias vector `b : Fin n → ℝ` encoding each node's self-model.

The **tropical reflective operator** at coordinate `i` computes:

  `R(x)(i) = min(b(i), min_{j ≠ i} (W(i,j) + x(j)))`

This combines two sources of information:
- The node's own self-model `b(i)` (intrinsic bias),
- The best incoming signal from other nodes `min_{j≠i}(W(i,j) + x(j))`.

## Main Results

Under **diagonal dominance** (`∀ i j, i ≠ j → b i < W i j + b j`):

1. **Existence**: `b` is a fixed point of the reflective operator.
2. **Uniqueness**: `b` is the *only* fixed point.
3. **Discrepancy characterization**: A state has zero discrepancy iff it is a fixed point.
4. **Broadcast property**: The fixed point satisfies global workspace broadcast.
5. **Conscious state identification**: The fixed point satisfies all consciousness criteria.

## Interpretation

The diagonal dominance condition means each node's self-model is strictly cheaper
than any indirect path through other nodes. Under this condition, self-reference
collapses to a unique equilibrium: the system "knows itself" exactly. This is the
tropical analog of a cognitive fixed point where self-modeling dynamics converge
to a stable, integrated, globally broadcast state.
-/

noncomputable section

open Finset

/-! ## Core Definitions -/

/-
Nonemptiness of `Finset.univ.erase i` when `n ≥ 2`.
-/
theorem erase_univ_nonempty {n : ℕ} (hn : 2 ≤ n) (i : Fin n) :
    (Finset.univ.erase i).Nonempty := by
  exact ⟨ if i = ⟨ 0, by linarith ⟩ then ⟨ 1, by linarith ⟩ else ⟨ 0, by linarith ⟩, by aesop ⟩

/-- The **tropical reflective operator**. At each coordinate `i`, computes
`min(b i, min_{j ≠ i}(W i j + x j))`. The off-diagonal minimum captures
how the system aggregates external influences, while the `min` with `b i`
ensures the self-model is always available as a fallback.

This is a Bellman-type operator from dynamic programming / shortest-path
theory, specialized to self-referential systems. -/
def tropReflect {n : ℕ} (hn : 2 ≤ n) (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (x : Fin n → ℝ) (i : Fin n) : ℝ :=
  min (b i) (Finset.inf' (Finset.univ.erase i) (erase_univ_nonempty hn i)
    (fun j => W i j + x j))

/-- **Tropical discrepancy**: measures how far a state is from equilibrium.
`∑ i |x i - R x i| = 0` iff `R x = x`. -/
def tropDiscrepancy {n : ℕ} (R : (Fin n → ℝ) → (Fin n → ℝ)) (x : Fin n → ℝ) : ℝ :=
  ∑ i, |x i - R x i|

/-- **Cut matrix**: retains weights within a partition block and sets
cross-partition weights to a large penalty `M`. -/
def cutMatrix {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (S : Finset (Fin n)) (M : ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => if (i ∈ S ↔ j ∈ S) then W i j else M

/-- **Global workspace broadcast**: every node's update value is attained
either through its bias term or through at least one incoming edge. -/
def Broadcasts {n : ℕ} (hn : 2 ≤ n) (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (x : Fin n → ℝ) : Prop :=
  ∀ i, b i = tropReflect hn W b x i ∨
    ∃ j, j ≠ i ∧ W i j + x j = tropReflect hn W b x i

/-- **Conscious state**: fixed point + broadcast + optimality among fixed points. -/
def IsConsciousState {n : ℕ} (hn : 2 ≤ n) (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (x : Fin n → ℝ) : Prop :=
  tropReflect hn W b x = x ∧ Broadcasts hn W b x ∧
  ∀ y, tropReflect hn W b y = y →
    tropDiscrepancy (tropReflect hn W b) y ≤ tropDiscrepancy (tropReflect hn W b) x

/-! ## Auxiliary Lemmas on Finset.inf' -/

/-
`inf'` over a finset is `≤` the value at any member.
-/
theorem inf'_le_val {n : ℕ} (hn : 2 ≤ n) (W : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (i j : Fin n) (hj : j ∈ Finset.univ.erase i) :
    Finset.inf' (Finset.univ.erase i) (erase_univ_nonempty hn i) (fun k => W i k + x k) ≤
      W i j + x j := by
  exact Finset.inf'_le _ hj

/-
The `inf'` is achieved by some element (finite minimum exists).
-/
theorem inf'_achieved {n : ℕ} (hn : 2 ≤ n) (W : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (i : Fin n) :
    ∃ j ∈ Finset.univ.erase i,
      Finset.inf' (Finset.univ.erase i) (erase_univ_nonempty hn i) (fun k => W i k + x k) =
        W i j + x j := by
  exact exists_mem_eq_inf' (erase_univ_nonempty hn i) fun k => W i k + x k

/-! ## Theorem 1: Fixed Point Existence -/

/-
Under separation, `b` is a fixed point of the tropical reflective operator.

**Proof**: For each `i`, we show `tropReflect hn W b b i = b i`.
By definition, this equals `min(b i, inf'_{j≠i}(W i j + b j))`.
By `hsep`, for all `j ≠ i`: `b i < W i j + b j`, so `inf'_{j≠i}(W i j + b j) > b i`.
(The inf' is achieved at some `j₀ ≠ i` with `W i j₀ + b j₀ > b i`.)
Hence `min(b i, inf') = b i`.
-/
theorem tropReflect_fixed_of_separated
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (hsep : ∀ i j, i ≠ j → b i < W i j + b j) :
    tropReflect hn W b b = b := by
  funext i;
  exact min_eq_left ( Finset.le_inf' _ _ fun j hj => le_of_lt ( hsep i j ( by aesop ) ) )

/-! ## Theorem 2: Fixed Point Uniqueness -/

/-
Under separation, any fixed point of the tropical reflective operator equals `b`.

**Proof**: Let `x` be a fixed point: `∀ i, x i = min(b i, inf'_{j≠i}(W i j + x j))`.
From the `min`, we get `x i ≤ b i` for all `i`. Now suppose `x ≠ b`, so there
exists `i₀` with `x i₀ < b i₀`. Then `x i₀ = inf'_{j≠i₀}(W i₀ j + x j)`.
This inf' is achieved at some `j₁ ≠ i₀`: `x i₀ = W i₀ j₁ + x j₁`.
Since `x j₁ ≤ b j₁`, we get `x i₀ ≤ W i₀ j₁ + b j₁`.
But by `hsep`: `b i₀ < W i₀ j₁ + b j₁`, so `x i₀ < W i₀ j₁ + b j₁` — no contradiction yet.
We need a subtler argument.

Consider `i₀` minimizing `x i - b i` (which is ≤ 0). At this `i₀`,
`x i₀ - b i₀ ≤ x j - b j` for all j, i.e., `x j ≥ x i₀ - b i₀ + b j`.
Then `x i₀ < b i₀`, so `x i₀ = W i₀ j₁ + x j₁` for some `j₁ ≠ i₀`.
`x j₁ ≥ x i₀ - b i₀ + b j₁`, so
`x i₀ = W i₀ j₁ + x j₁ ≥ W i₀ j₁ + x i₀ - b i₀ + b j₁ = W i₀ j₁ + b j₁ + (x i₀ - b i₀)`.
Thus `x i₀ ≥ W i₀ j₁ + b j₁ + x i₀ - b i₀`, giving `b i₀ ≥ W i₀ j₁ + b j₁`.
But `hsep` says `b i₀ < W i₀ j₁ + b j₁`. Contradiction. So `x = b`.
-/
theorem tropReflect_fixed_unique
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (hsep : ∀ i j, i ≠ j → b i < W i j + b j) :
    ∀ x, tropReflect hn W b x = x → x = b := by
  intros x hx
  by_contra h_neq;
  -- Choose $i₀$ minimizing $(x i - b i)$, equivalently maximizing $(b i - x i)$.
  obtain ⟨i₀, hi₀⟩ : ∃ i₀ : Fin n, ∀ i : Fin n, x i - b i ≥ x i₀ - b i₀ := by
    cases n <;> [ tauto; simpa using Finset.exists_min_image Finset.univ ( fun i => x i - b i ) ⟨ ⟨ 0, by linarith ⟩, Finset.mem_univ _ ⟩ ];
  -- Since $x i₀ < b i₀$, we have $x i₀ = \inf'_{j≠i₀}(W i₀ j + x j)$.
  have h_inf : x i₀ = Finset.inf' (Finset.univ.erase i₀) (erase_univ_nonempty hn i₀) (fun j => W i₀ j + x j) := by
    have h_inf : x i₀ < b i₀ := by
      exact lt_of_le_of_ne ( by have := congr_fun hx i₀; exact this.symm ▸ min_le_left _ _ ) fun h => h_neq <| funext fun i => by have := congr_fun hx i; have := hi₀ i; norm_num [ tropReflect ] at *; linarith [ min_le_left ( b i ) ( Finset.inf' ( Finset.univ.erase i ) ( erase_univ_nonempty hn i ) fun k => W i k + x k ), min_le_right ( b i ) ( Finset.inf' ( Finset.univ.erase i ) ( erase_univ_nonempty hn i ) fun k => W i k + x k ) ] ;
    have := congr_fun hx i₀;
    grind +locals;
  -- By inf'_achieved, there exists j₁ ≠ i₀ with x i₀ = W i₀ j₁ + x j₁.
  obtain ⟨j₁, hj₁_ne_i₀, hj₁_eq⟩ : ∃ j₁ : Fin n, j₁ ≠ i₀ ∧ x i₀ = W i₀ j₁ + x j₁ := by
    have := Finset.exists_mem_eq_inf' ( erase_univ_nonempty hn i₀ ) ( fun j => W i₀ j + x j ) ; aesop;
  grind

/-- **Main Theorem**: Under separation, the tropical reflective operator has a
unique fixed point, namely `b`. This is the tropical reflective equilibrium. -/
theorem tropReflect_unique_fixed_point
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (hsep : ∀ i j, i ≠ j → b i < W i j + b j) :
    ∃! x : Fin n → ℝ, tropReflect hn W b x = x := by
  exact ⟨b, tropReflect_fixed_of_separated hn W b hsep,
    fun y hy => (tropReflect_fixed_unique hn W b hsep y hy)⟩

/-! ## Theorem 3: Discrepancy Characterization -/

/-
Discrepancy vanishes iff the state is a fixed point.
-/
theorem tropDiscrepancy_eq_zero_iff
    {n : ℕ}
    (R : (Fin n → ℝ) → (Fin n → ℝ)) (x : Fin n → ℝ) :
    tropDiscrepancy R x = 0 ↔ R x = x := by
  unfold tropDiscrepancy;
  rw [ Finset.sum_eq_zero_iff_of_nonneg ] <;> simp +decide [ sub_eq_zero, funext_iff ];
  exact forall_congr' fun _ => eq_comm

/-
Discrepancy is always nonnegative.
-/
theorem tropDiscrepancy_nonneg
    {n : ℕ}
    (R : (Fin n → ℝ) → (Fin n → ℝ)) (x : Fin n → ℝ) :
    0 ≤ tropDiscrepancy R x := by
  -- The sum of non-negative terms is non-negative.
  apply Finset.sum_nonneg; intro i _; apply abs_nonneg

/-- The fixed point achieves zero discrepancy, which is the global minimum. -/
theorem fixed_point_minimizes_discrepancy
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (hsep : ∀ i j, i ≠ j → b i < W i j + b j) :
    tropDiscrepancy (tropReflect hn W b) b = 0 := by
  rw [tropDiscrepancy_eq_zero_iff]
  exact tropReflect_fixed_of_separated hn W b hsep

/-
Non-fixed points have strictly positive discrepancy.
-/
theorem tropDiscrepancy_pos_of_ne_fixed
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (hsep : ∀ i j, i ≠ j → b i < W i j + b j)
    (x : Fin n → ℝ) (hx : x ≠ b) :
    0 < tropDiscrepancy (tropReflect hn W b) x := by
  apply lt_of_le_of_ne; exact tropDiscrepancy_nonneg (tropReflect hn W b) x; exact Ne.symm (by
  exact fun h => hx <| tropReflect_fixed_unique hn W b hsep x <| tropDiscrepancy_eq_zero_iff _ _ |>.1 h)

/-! ## Theorem 4: Broadcast Property -/

/-
The fixed point `b` satisfies broadcast: at each node, the update
is determined by the bias term (since the bias wins under separation).
-/
theorem b_broadcasts
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (hsep : ∀ i j, i ≠ j → b i < W i j + b j) :
    Broadcasts hn W b b := by
  intro i;
  rw [ tropReflect_fixed_of_separated hn W b hsep ];
  exact Or.inl rfl

/-! ## Theorem 5: Conscious State Identification -/

/-- **The Tropical Consciousness Theorem**: Under diagonal dominance, `b` is the
unique conscious state. It is simultaneously a fixed point of min-plus
self-referential dynamics, a global broadcaster, and optimal among all fixed
points. -/
theorem b_isConsciousState
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (hsep : ∀ i j, i ≠ j → b i < W i j + b j) :
    IsConsciousState hn W b b := by
  refine ⟨tropReflect_fixed_of_separated hn W b hsep,
         b_broadcasts hn W b hsep,
         fun y hy => ?_⟩
  have heq : y = b := tropReflect_fixed_unique hn W b hsep y hy
  rw [heq]

/-! ## Theorem 6: Monotone Contraction -/

/-
The tropical reflective operator is coordinatewise ≤ `b`.
-/
theorem tropReflect_le_b
    {n : ℕ} (hn : 2 ≤ n) (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (x : Fin n → ℝ) (i : Fin n) :
    tropReflect hn W b x i ≤ b i := by
  exact min_le_left _ _

/-
Iterating tropReflect from above (starting at `b`) stays at `b`.
-/
theorem iterate_tropReflect_from_b
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (hsep : ∀ i j, i ≠ j → b i < W i j + b j)
    (k : ℕ) :
    (tropReflect hn W b)^[k] b = b := by
  induction k <;> simp_all +decide [Function.iterate_succ_apply']
  exact tropReflect_fixed_of_separated hn W b hsep

end