import Mathlib

/-!
# Descent Basin Theory

We develop a combinatorial theory of gradient descent basins on finite optimization
landscapes. The central result is that the set of gradient descent basins coincides
exactly with the set of fixed points (local minima) of the descent map.

This formalizes the combinatorial core of the conjecture that enumerative invariants
of neural network loss landscapes count the number of distinct gradient descent basins.

## Main Results

* `DescentSystem.basin_isFixedPoint` — The basin map lands on a fixed point
* `DescentSystem.basin_image_eq_fixedPoints` — Basins = fixed points as sets
* `DescentSystem.basin_equivariant` — Landscape symmetries permute basins
* `DescentSystem.prod_basin` — Product landscape basins decompose componentwise

## Mathematical Context

For a neural network loss landscape equipped with a Lyapunov (cost) function,
gradient descent defines a discrete dynamical system. The *basin* of a point is the
local minimum it converges to. The Basin Fixed Point Theorem shows this is well-defined
for any finite landscape with strict Lyapunov descent, and the correspondence theorem
shows basin count = fixed point count — the discrete analogue of the Morse-theoretic
statement relating critical points to sublevel set topology.
-/

noncomputable section
open Function Fintype Finset

/-- A descent system on a finite type `α`: a self-map `d` with a real-valued Lyapunov
    function `f` that strictly decreases at every non-fixed point. This models
    gradient descent on a discrete optimization landscape. -/
structure DescentSystem (α : Type*) [Fintype α] where
  /-- The descent (gradient step) map -/
  d : α → α
  /-- Lyapunov (cost/loss) function -/
  f : α → ℝ
  /-- Cost strictly decreases at non-fixed points -/
  strict_descent : ∀ x, d x ≠ x → f (d x) < f x

namespace DescentSystem

variable {α : Type*} [Fintype α] [DecidableEq α] (S : DescentSystem α)

/-
═══════════════════════════════════════════════════
Section 1: Foundational lemmas
═══════════════════════════════════════════════════

The Lyapunov function never increases along the descent map.
-/
lemma descent_le (x : α) : S.f (S.d x) ≤ S.f x := by
  by_cases hx : S.d x = x;
  · rw [ hx ];
  · exact le_of_lt ( S.strict_descent x hx )

/-
Iterating a fixed point of `d` always returns the same point.
-/
omit [DecidableEq α] in
lemma iterate_of_fixed {y : α} (hy : S.d y = y) (n : ℕ) : S.d^[n] y = y := by
  induction n <;> simp +decide [ *, Function.iterate_succ_apply' ]

/-
The Lyapunov function is non-increasing along orbits.
-/
lemma f_iterate_le (x : α) (n : ℕ) : S.f (S.d^[n + 1] x) ≤ S.f (S.d^[n] x) := by
  simpa only [ Function.iterate_succ_apply' ] using S.descent_le _

/-
═══════════════════════════════════════════════════
Section 2: Orbit analysis
═══════════════════════════════════════════════════

Along a segment of an orbit where no point is fixed, f is strictly decreasing,
    so the orbit visits distinct points (injectivity on orbit indices).
-/
omit [DecidableEq α] in
lemma orbit_injective_of_nonfixed {x : α} {n : ℕ}
    (hnf : ∀ k, k < n → S.d^[k + 1] x ≠ S.d^[k] x)
    {i j : ℕ} (hi : i ≤ n) (hj : j ≤ n) (heq : S.d^[i] x = S.d^[j] x) :
    i = j := by
      -- By induction on the difference between j and i, we can show that f(d^i x) > f(d^j x) if i < j and all intermediate points are nonfixed.
      have h_ind : ∀ k l : ℕ, k < l → l ≤ n → (∀ m ∈ Finset.Ico k l, S.d^[m + 1] x ≠ S.d^[m] x) → S.f (S.d^[k] x) > S.f (S.d^[l] x) := by
        intro k l hkl hln h; induction hkl <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
        · exact S.strict_descent _ ( hnf _ hln );
        · rename_i m hm ih;
          exact lt_trans ( S.strict_descent _ ( h _ ( by linarith ) ( by linarith ) ) ) ( ih ( by linarith ) fun n hn₁ hn₂ => h _ hn₁ ( by linarith ) );
      contrapose! h_ind;
      cases lt_or_gt_of_ne h_ind <;> [ exact ⟨ i, j, ‹_›, ‹_›, fun m hm => hnf m ( by linarith [ Finset.mem_Ico.mp hm ] ), by simp +decide [ heq ] ⟩ ; exact ⟨ j, i, ‹_›, ‹_›, fun m hm => hnf m ( by linarith [ Finset.mem_Ico.mp hm ] ), by simp +decide [ heq.symm ] ⟩ ]

/-
**Key Lemma**: Within the first `card α` iterates, some iterate must be a
    fixed point. (By pigeonhole: a non-fixed orbit of length > card α would
    require more than card α distinct elements.)
-/
theorem exists_fixed_in_orbit (x : α) :
    ∃ k, k < card α ∧ S.d (S.d^[k] x) = S.d^[k] x := by
      by_contra! h;
      -- By the properties of the descent map and the Lyapunov function, the sequence $d^[k] x$ must be injective.
      have h_injective : ∀ i j : ℕ, i ≤ Fintype.card α → j ≤ Fintype.card α → S.d^[i] x = S.d^[j] x → i = j := by
        apply_rules [ orbit_injective_of_nonfixed ];
        simpa only [ Function.iterate_succ_apply' ] using h;
      exact absurd ( Finset.card_le_univ ( Finset.image ( fun k => S.d^[k] x ) ( Finset.Iic ( Fintype.card α ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => h_injective i j ( Finset.mem_Iic.mp hi ) ( Finset.mem_Iic.mp hj ) hij ] ; simp +decide )

-- ═══════════════════════════════════════════════════
-- Section 3: Basin map — definition and main theorem
-- ═══════════════════════════════════════════════════

/-- The **basin** of `x`: iterate descent `card α` times to reach a fixed point.
    This is the discrete analogue of following gradient flow to convergence. -/
def basin (x : α) : α := S.d^[card α] x

/-
**Basin Fixed Point Theorem (Theorem 1)**: The basin of any point is a
    fixed point of the descent map. Every gradient descent trajectory converges.
-/
theorem basin_isFixedPoint (x : α) : S.d (S.basin x) = S.basin x := by
  obtain ⟨ k, hk₁, hk₂ ⟩ := exists_fixed_in_orbit S x;
  -- By definition of basin, we have S.basin x = S.d^[Fintype.card α] x.
  unfold DescentSystem.basin;
  rw [ ← Nat.sub_add_cancel hk₁.le, Function.iterate_add_apply ];
  induction' Fintype.card α - k with n ih <;> simp_all +decide [ Function.iterate_succ_apply' ]

/-
A fixed point is its own basin.
-/
omit [DecidableEq α] in
theorem basin_of_fixed {x : α} (hx : S.d x = x) : S.basin x = x := by
  exact Function.iterate_fixed hx _

/-
**Basin–Fixed Point Correspondence (Theorem 2)**: The image of the basin map
    is exactly the set of fixed points. Basin count = local minima count.
-/
theorem basin_image_eq_fixedPoints :
    image S.basin univ = univ.filter (fun x => S.d x = x) := by
      -- To prove equality of finite sets, we show each set is a subset of the other.
      apply Finset.ext
      intro y
      simp [Finset.mem_image];
      constructor <;> intro h;
      · obtain ⟨ x, rfl ⟩ := h; exact S.basin_isFixedPoint x;
      · exact ⟨ y, S.basin_of_fixed h ⟩

/-
─── PEGB: Example ───

Concrete 3-vertex landscape with two basins: vertex 1 flows to vertex 0.
-/
example : let S : DescentSystem (Fin 3) := ⟨
    (fun | 0 => 0 | 1 => 0 | 2 => 2),
    (fun | 0 => (0 : ℝ) | 1 => 1 | 2 => 0),
    (by intro x hx; fin_cases x <;> simp_all)⟩
  S.basin 1 = 0 ∧ S.d (S.basin 1) = S.basin 1 := by
    unfold DescentSystem.basin; native_decide;

/-
─── PEGB: Generalization ───

Works with ℕ-valued Lyapunov functions (well-founded descent).
-/
theorem basin_isFixedPoint_nat {α : Type*} [Fintype α] [DecidableEq α]
    {d : α → α} {f : α → ℕ}
    (hd : ∀ x, d x ≠ x → f (d x) < f x) (x : α) :
    d (d^[card α] x) = d^[card α] x := by
      convert DescentSystem.basin_isFixedPoint _ _;
      any_goals exact DescentSystem.mk d ( fun x => f x ) ( fun x hx => Nat.cast_lt.mpr ( hd x hx ) );
      · rfl;
      · rfl;
      · rfl;
      · infer_instance

/-
─── PEGB: Boundary ───

Without a Lyapunov function, maps can have no fixed points (cycling).
-/
theorem no_lyapunov_no_basin :
    ∃ d : Fin 2 → Fin 2, ∀ x, d x ≠ x := by
      native_decide +revert

/-
═══════════════════════════════════════════════════
Section 4: Equivariance — symmetries permute basins
═══════════════════════════════════════════════════

Maps commuting with `d` commute with any iterate of `d`.
-/
omit [DecidableEq α] in
lemma iterate_commute_of_commute (σ : α → α)
    (hcomm : ∀ x, S.d (σ x) = σ (S.d x)) (n : ℕ) (x : α) :
    S.d^[n] (σ x) = σ (S.d^[n] x) := by
      induction' n with n ih <;> simp +decide [ *, Function.iterate_succ_apply' ]

/-
**Basin Equivariance Theorem (Theorem 3)**: Any map commuting with `d`
    commutes with the basin map. Landscape symmetries permute basins.
-/
omit [DecidableEq α] in
theorem basin_equivariant (σ : α → α)
    (hcomm : ∀ x, S.d (σ x) = σ (S.d x)) (x : α) :
    S.basin (σ x) = σ (S.basin x) := by
      convert iterate_commute_of_commute S σ hcomm _ _

-- ─── PEGB: Example ───
/-- The identity trivially commutes with any basin map. -/
example (S : DescentSystem α) (x : α) : S.basin (id x) = id (S.basin x) := rfl

/-
─── PEGB: Generalization ───

Extends to group actions: if G acts on α commuting with d, it acts on basins.
-/
omit [DecidableEq α] in
theorem basin_equivariant_smul {G : Type*} [Group G] [MulAction G α]
    (hcomm : ∀ (g : G) (x : α), S.d (g • x) = g • S.d x)
    (g : G) (x : α) : S.basin (g • x) = g • S.basin x := by
      convert S.basin_equivariant ( fun y => g • y ) ( fun y => by simp +decide [ hcomm ] ) x using 1

/-
─── PEGB: Boundary ───

Non-commuting maps need not preserve basins.
    d: 0↦0, 1↦0, 2↦2; σ: 0↦0, 1↦2, 2↦1.
    basin(σ(1)) = basin(2) = 2, but σ(basin(1)) = σ(0) = 0.
-/
theorem noncommuting_breaks_equivariance :
    ∃ (S : DescentSystem (Fin 3)) (σ : Fin 3 → Fin 3),
    (∃ x, S.d (σ x) ≠ σ (S.d x)) ∧
    (∃ x, S.basin (σ x) ≠ σ (S.basin x)) := by
      fconstructor;
      constructor;
      rotate_left;
      exact fun x => if x = 0 then 0 else if x = 1 then 0 else 2;
      exact fun x => if x = 0 then 0 else if x = 1 then 1 else 2;
      simp +decide [ DescentSystem.basin ];
      norm_cast

-- ═══════════════════════════════════════════════════
-- Section 5: Product decomposition
-- ═══════════════════════════════════════════════════

variable {β : Type*} [Fintype β] [DecidableEq β]

/-
Product of two descent systems on `α × β`. The Lyapunov function is the sum.
-/
def prod (S₁ : DescentSystem α) (S₂ : DescentSystem β) : DescentSystem (α × β) where
  d := fun p => (S₁.d p.1, S₂.d p.2)
  f := fun p => S₁.f p.1 + S₂.f p.2
  strict_descent := by
    intro x hx;
    by_cases h₁ : S₁.d x.1 = x.1 <;> by_cases h₂ : S₂.d x.2 = x.2 <;> simp_all +decide;
    · exact S₂.strict_descent _ h₂;
    · exact S₁.strict_descent x.1 h₁;
    · exact add_lt_add_of_lt_of_le ( S₁.strict_descent _ h₁ ) ( S₂.descent_le _ )

/-
Iteration in a product system decomposes componentwise.
-/
lemma prod_iterate_eq (S₁ : DescentSystem α) (S₂ : DescentSystem β)
    (p : α × β) (n : ℕ) :
    (S₁.prod S₂).d^[n] p = (S₁.d^[n] p.1, S₂.d^[n] p.2) := by
      induction n <;> simp +decide [ *, Function.iterate_succ_apply' ];
      rfl

/-
Basin stabilization: iterating `d` beyond `card α` steps gives the same result
    as the basin. Extra iterations don't move a fixed point.
-/
lemma basin_stabilize {n : ℕ} (hn : card α ≤ n) (x : α) :
    S.d^[n] x = S.basin x := by
      convert iterate_of_fixed S ( basin_isFixedPoint S x ) ( n - Fintype.card α ) using 1;
      unfold DescentSystem.basin; rw [ ← Function.iterate_add_apply, Nat.sub_add_cancel hn ] ;

/-
**Product Basin Theorem (Theorem 4)**: Basins of product landscapes decompose
    componentwise. The basin of (x₁, x₂) in the product is (basin x₁, basin x₂).
-/
theorem prod_basin (S₁ : DescentSystem α) (S₂ : DescentSystem β)
    (x₁ : α) (x₂ : β) :
    (S₁.prod S₂).basin (x₁, x₂) = (S₁.basin x₁, S₂.basin x₂) := by
      -- By definition of `basin`, we know that
      unfold DescentSystem.basin;
      rw [ prod_iterate_eq ];
      simp +decide [ Fintype.card_prod ];
      constructor;
      · convert S₁.basin_stabilize _ x₁;
        exact le_mul_of_one_le_right ( Nat.zero_le _ ) ( Fintype.card_pos_iff.mpr ⟨ x₂ ⟩ );
      · convert S₂.basin_stabilize _ _;
        exact le_mul_of_one_le_left ( Nat.zero_le _ ) ( Fintype.card_pos_iff.mpr ⟨ x₁ ⟩ )

/-
─── PEGB: Generalization ───

The number of fixed points of the product = product of fixed point counts.
-/
theorem prod_fixedPoint_card (S₁ : DescentSystem α) (S₂ : DescentSystem β) :
    card {p : α × β // (S₁.prod S₂).d p = p} =
    card {x : α // S₁.d x = x} * card {y : β // S₂.d y = y} := by
      simp +decide [ Fintype.card_subtype ];
      rw [ ← Finset.card_product ];
      refine' Finset.card_bij ( fun x _ => ( x.1, x.2 ) ) _ _ _ <;> simp +decide;
      · unfold DescentSystem.prod; aesop;
      · exact fun a b ha hb => Prod.ext ha hb

end DescentSystem
end