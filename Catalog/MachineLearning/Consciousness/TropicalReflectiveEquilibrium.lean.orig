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

/-- Nonemptiness of `Finset.univ.erase i` when `n ≥ 2`. -/
theorem erase_univ_nonempty {n : ℕ} (hn : 2 ≤ n) (i : Fin n) :
    (Finset.univ.erase i).Nonempty := by
  refine ⟨if i = ⟨0, by omega⟩ then ⟨1, by omega⟩ else ⟨0, by omega⟩, ?_⟩
  simp only [Finset.mem_erase, Finset.mem_univ, and_true]
  split
  all_goals simp_all [Fin.ext_iff]
  all_goals omega

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

/-- **Tropical integrated information** (Phi): measures the minimum
integration penalty across all nontrivial partitions. For each partition
defined by a set `S`, we compare the discrepancy under the full operator
versus the decoupled (cut) operator. -/
def tropicalPhi {n : ℕ} (hn : 2 ≤ n) (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (M : ℝ) (x : Fin n → ℝ) : ℝ :=
  Finset.inf' (Finset.univ.filter (fun S : Finset (Fin n) => S.Nonempty ∧ S ≠ Finset.univ))
    (by
      refine ⟨{⟨0, by omega⟩}, ?_⟩
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      exact ⟨⟨_, Finset.mem_singleton_self _⟩,
        fun h => by simp [Finset.eq_univ_iff_forall] at h; exact absurd (h ⟨1, by omega⟩) (by simp [Fin.ext_iff])⟩)
    (fun S =>
      tropDiscrepancy (tropReflect hn (cutMatrix W S M) b) x -
      tropDiscrepancy (tropReflect hn W b) x)

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

/-! ## Theorem 1: Fixed Point Existence -/

/-
Under separation, `b` is a fixed point of the tropical reflective operator.

**Proof**: For each `i`, the `min` selects `b i` because all off-diagonal terms
`W i j + b j > b i` by the separation hypothesis.
-/
theorem tropReflect_fixed_of_separated
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (hsep : ∀ i j, i ≠ j → b i < W i j + b j) :
    tropReflect hn W b b = b := by
  ext i;
  exact min_eq_left ( Finset.le_inf' _ _ fun j hj => le_of_lt ( hsep i j ( by aesop ) ) )

/-! ## Theorem 2: Fixed Point Uniqueness -/

/-
Under separation, any fixed point must equal `b`.

**Proof sketch**: From the `min`, any fixed point satisfies `x i ≤ b i`.
If `x ≠ b`, pick `i₀` minimizing `x i - b i`. Then `x i₀ < b i₀`, so the
min selects the inf' term. The inf' is achieved at some `j₁ ≠ i₀` with
`x i₀ = W i₀ j₁ + x j₁ ≥ W i₀ j₁ + b j₁ + (x i₀ - b i₀)`, giving
`b i₀ ≥ W i₀ j₁ + b j₁`, contradicting separation.
-/
theorem tropReflect_fixed_unique
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (hsep : ∀ i j, i ≠ j → b i < W i j + b j) :
    ∀ x, tropReflect hn W b x = x → x = b := by
  intro x hx;
  -- For each `i`, the `min` selects `b i` because all off-diagonal terms `W i j + b j > b i` by the separation hypothesis.
  have h_min : ∀ i, x i ≤ b i := by
    exact fun i => hx ▸ min_le_left _ _;
  -- Suppose x ≠ b. Pick i₀ minimizing (x i - b i) over all Fin n using Finset.exists_min_image. Since x ≠ b, there exists some i with x i < b i, and i₀ has x i₀ - b i₀ ≤ x i - b i for all i, so x i₀ < b i₀.
  by_contra h_neq
  obtain ⟨i₀, hi₀⟩ : ∃ i₀, x i₀ < b i₀ ∧ ∀ i, x i - b i ≥ x i₀ - b i₀ := by
    obtain ⟨i₀, hi₀⟩ : ∃ i₀, x i₀ < b i₀ := by
      exact Function.ne_iff.mp h_neq |> Exists.imp fun i hi => lt_of_le_of_ne ( h_min i ) hi;
    exact Finset.exists_min_image Finset.univ ( fun i => x i - b i ) ⟨ i₀, Finset.mem_univ i₀ ⟩ |> fun ⟨ i₁, hi₁ ⟩ => ⟨ i₁, by linarith [ hi₁.2 i₀ ( Finset.mem_univ i₀ ) ], fun i => hi₁.2 i ( Finset.mem_univ i ) ⟩;
  -- Since $x i₀ = \min(b i₀, \inf'_{j \neq i₀}(W i₀ j + x j))$ and $x i₀ < b i₀$, we must have $x i₀ = \inf'_{j \neq i₀}(W i₀ j + x j)$.
  have h_inf : x i₀ = Finset.inf' (Finset.univ.erase i₀) (erase_univ_nonempty hn i₀) (fun j => W i₀ j + x j) := by
    have := congr_fun hx i₀;
    unfold tropReflect at this;
    grind +qlia;
  -- By exists_mem_eq_inf', there exists j₁ ≠ i₀ with x i₀ = W i₀ j₁ + x j₁.
  obtain ⟨j₁, hj₁_ne_i₀, hj₁_eq⟩ : ∃ j₁, j₁ ≠ i₀ ∧ x i₀ = W i₀ j₁ + x j₁ := by
    have := Finset.exists_mem_eq_inf' ( erase_univ_nonempty hn i₀ ) ( fun j => W i₀ j + x j ) ; aesop;
  linarith [ hsep i₀ j₁ ( Ne.symm hj₁_ne_i₀ ), h_min j₁, hi₀.2 j₁ ]

/-- **Main Theorem**: Under separation, the tropical reflective operator has a
unique fixed point, namely `b`. This is the tropical reflective equilibrium. -/
theorem tropReflect_unique_fixed_point
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (hsep : ∀ i j, i ≠ j → b i < W i j + b j) :
    ∃! x : Fin n → ℝ, tropReflect hn W b x = x :=
  ⟨b, tropReflect_fixed_of_separated hn W b hsep,
    fun y hy => tropReflect_fixed_unique hn W b hsep y hy⟩

/-! ## Theorem 3: Discrepancy Characterization -/

/-
Discrepancy vanishes iff the state is a fixed point.
-/
theorem tropDiscrepancy_eq_zero_iff
    {n : ℕ}
    (R : (Fin n → ℝ) → (Fin n → ℝ)) (x : Fin n → ℝ) :
    tropDiscrepancy R x = 0 ↔ R x = x := by
  constructor;
  · exact fun h => funext fun i => eq_comm.mp <| sub_eq_zero.mp <| abs_eq_zero.mp <| by rw [ tropDiscrepancy ] at h; exact Finset.sum_eq_zero_iff_of_nonneg ( fun _ _ => abs_nonneg _ ) |>.mp h i <| Finset.mem_univ i;
  · unfold tropDiscrepancy; aesop;

/-
Discrepancy is always nonnegative.
-/
theorem tropDiscrepancy_nonneg
    {n : ℕ}
    (R : (Fin n → ℝ) → (Fin n → ℝ)) (x : Fin n → ℝ) :
    0 ≤ tropDiscrepancy R x := by
  exact Finset.sum_nonneg fun i _ => abs_nonneg _

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
  exact lt_of_le_of_ne ( tropDiscrepancy_nonneg _ _ ) ( Ne.symm ( by simpa [ hx ] using tropDiscrepancy_eq_zero_iff ( tropReflect hn W b ) x |>.not.mpr ( by simpa [ hx ] using tropReflect_fixed_unique hn W b hsep x ) ) )

/-! ## Theorem 4: Broadcast Property -/

/-- The fixed point `b` satisfies broadcast: at each node, the update
is determined by the bias term (since the bias wins under separation). -/
theorem b_broadcasts
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (hsep : ∀ i j, i ≠ j → b i < W i j + b j) :
    Broadcasts hn W b b := by
  intro i
  left
  rw [tropReflect_fixed_of_separated hn W b hsep]

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

/-! ## Theorem 6: Upper Bound and Iteration Properties -/

/-- The tropical reflective operator is coordinatewise ≤ `b`. -/
theorem tropReflect_le_b
    {n : ℕ} (hn : 2 ≤ n) (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (x : Fin n → ℝ) (i : Fin n) :
    tropReflect hn W b x i ≤ b i :=
  min_le_left _ _

/-- Iterating `tropReflect` from `b` stays at `b`. -/
theorem iterate_tropReflect_from_b
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (hsep : ∀ i j, i ≠ j → b i < W i j + b j)
    (k : ℕ) :
    (tropReflect hn W b)^[k] b = b := by
  induction k with
  | zero => simp
  | succ k ih => simp [Function.iterate_succ_apply', ih, tropReflect_fixed_of_separated hn W b hsep]

/-! ## Theorem 7: Stronger Unique Fixed Point Statement -/

/-- The unique fixed point is exactly `b` — combining existence, uniqueness,
and identification in a single statement. -/
theorem tropReflect_unique_fixed_point_eq_bias
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (hsep : ∀ i j, i ≠ j → b i < W i j + b j) :
    ∃! x : Fin n → ℝ, tropReflect hn W b x = x ∧ x = b := by
  exact ⟨b, ⟨tropReflect_fixed_of_separated hn W b hsep, rfl⟩,
    fun y ⟨hy, _⟩ => tropReflect_fixed_unique hn W b hsep y hy⟩

/-! ## Min-Plus Idempotent Lemmas -/

/-- `min` is idempotent: `min a a = a`. A foundational fact for tropical algebra. -/
theorem min_self_idempotent (a : ℝ) : min a a = a := min_self a

/-- `max` is idempotent: `max a a = a`. The dual idempotent law. -/
theorem tropical_self_max_idempotent (a : ℝ) : max a a = a := max_self a

/-
An idempotent function on a finite type has a fixed point:
applying it twice gives the same result as applying once, so any
value in the image is a fixed point.
-/
theorem finite_idempotent_fixed_point {α : Type*} [Fintype α] [Nonempty α]
    (f : α → α) (h_idem : f ∘ f = f) :
    ∃ a, f a = a := by
  exact ⟨ f ( Classical.arbitrary α ), congr_fun h_idem ( Classical.arbitrary α ) ⟩

/-- A self-modeling system is a structure with a state space and a
reflection (self-model) endomorphism. -/
structure SelfModelingSystem where
  State : Type*
  reflect : State → State

/-- Self-equivalence of fixed points: a fixed point of `reflect` is unchanged
by further applications. -/
theorem fixed_point_self_equiv (S : SelfModelingSystem) (s : S.State)
    (hs : S.reflect s = s) (k : ℕ) :
    S.reflect^[k] s = s := by
  induction k with
  | zero => simp
  | succ k ih => simp [Function.iterate_succ_apply', ih, hs]

end