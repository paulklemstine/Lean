import Mathlib

/-!
# Weighted Tree Automata: Tropical Closure Properties

We formalize weighted bottom-up tree automata over ranked signatures with costs
valued in `ENNReal` (extended non-negative reals), the natural tropical semiring.

## Main results

- `WTA.evalState_product`: The product automaton computes the sum of component costs
  at each state pair (the stronger state-indexed theorem).
- `WTA.eval_product`: Tropical product closure — the class of recognizable tree series
  is closed under pointwise addition.
- `WTA.evalState_union_inl`/`WTA.evalState_union_inr`: The union automaton preserves
  component semantics on each side of the disjoint sum.
- `WTA.eval_union`: Tropical union closure — the class of recognizable tree series
  is closed under pointwise infimum (min).

## Mathematical significance

These results establish that tropical-recognizable tree series form a sub-semiring
of the semiring of all tree series under tropical operations. The product theorem
is a "min-plus Fubini principle": independent costs on subtrees compose additively,
and the global optimum on paired runs decomposes. The union theorem shows tropical
recognizability is closed under competitive model aggregation.
-/

open ENNReal

namespace TreeAutomata

/-! ## Ranked Trees -/

/-- Ranked trees over a signature `σ` with arity function `ar`. -/
inductive RTree (σ : Type*) (ar : σ → ℕ) : Type _
  | node (a : σ) (children : Fin (ar a) → RTree σ ar) : RTree σ ar

/-! ## Weighted Tree Automata -/

/-- A weighted bottom-up tree automaton with costs in `ENNReal`.
    - `delta a f q` is the transition cost for symbol `a` with child states given by `f`,
      transitioning to state `q`.
    - `finalCost q` is the cost of accepting in state `q`. -/
structure WTA (σ : Type*) (ar : σ → ℕ) (Q : Type*) where
  delta : (a : σ) → (Fin (ar a) → Q) → Q → ENNReal
  finalCost : Q → ENNReal

variable {σ : Type*} {ar : σ → ℕ}

/-! ## Semantics -/

/-- The minimum cost of processing tree `t` and arriving at state `q`,
    computed by structural recursion on the tree (dynamic programming). -/
noncomputable def WTA.evalState {Q : Type*} (A : WTA σ ar Q) :
    RTree σ ar → Q → ENNReal
  | .node a children => fun q =>
    ⨅ f : Fin (ar a) → Q,
      A.delta a f q + ∑ i : Fin (ar a), A.evalState (children i) (f i)

/-- The minimum cost of processing tree `t` over all accepting runs. -/
noncomputable def WTA.eval {Q : Type*} (A : WTA σ ar Q) (t : RTree σ ar) : ENNReal :=
  ⨅ q : Q, A.evalState t q + A.finalCost q

/-! ## Unfolding lemma -/

theorem WTA.evalState_node {Q : Type*} (A : WTA σ ar Q)
    (a : σ) (children : Fin (ar a) → RTree σ ar) (q : Q) :
    A.evalState (.node a children) q =
      ⨅ f : Fin (ar a) → Q,
        A.delta a f q + ∑ i, A.evalState (children i) (f i) := by
  rfl

/-! ## Product Automaton -/

/-- The product automaton of two WTAs. State space is the Cartesian product.
    Transition costs are sums of the component costs. This realizes the
    tropical product (pointwise addition) of the two tree series. -/
noncomputable def WTA.product {Q₁ Q₂ : Type*}
    (A₁ : WTA σ ar Q₁) (A₂ : WTA σ ar Q₂) :
    WTA σ ar (Q₁ × Q₂) where
  delta a f q := A₁.delta a (Prod.fst ∘ f) q.1 + A₂.delta a (Prod.snd ∘ f) q.2
  finalCost q := A₁.finalCost q.1 + A₂.finalCost q.2

/-! ### Helper: Min-plus Fubini for iInf

The key algebraic identity: the infimum of `f(x) + g(y)` over a product
type equals the sum of the infima of `f` and `g` separately. -/

/-
Min-plus Fubini: `⨅ (p : α × β), (f p.1 + g p.2) = (⨅ a, f a) + (⨅ b, g b)`.
-/
theorem iInf_add_iInf_eq_iInf_prod {α β : Type*} (f : α → ENNReal) (g : β → ENNReal) :
    (⨅ a, f a) + (⨅ b, g b) = ⨅ p : α × β, f p.1 + g p.2 := by
  -- Rewrite the right-hand side using the definition of infimum over a product type.
  have h_rhs : ⨅ p : α × β, f p.1 + g p.2 = ⨅ a, ⨅ b, f a + g b :=
    (iInf_prod' fun i j => f i + g j).symm;
  simp_all +decide [ ENNReal.add_iInf, ENNReal.iInf_add ];
  rw [ iInf_comm ]

/-! ### Product Theorem -/

/-
**Key theorem (statewise)**: The product automaton's state cost decomposes as
    the sum of component state costs. Proved by structural induction on trees,
    using the min-plus Fubini principle to separate independent state choices.
-/
theorem WTA.evalState_product {Q₁ Q₂ : Type*}
    (A₁ : WTA σ ar Q₁) (A₂ : WTA σ ar Q₂)
    (t : RTree σ ar) (q₁ : Q₁) (q₂ : Q₂) :
    (A₁.product A₂).evalState t (q₁, q₂) =
      A₁.evalState t q₁ + A₂.evalState t q₂ := by
  induction' t with a children ih generalizing q₁ q₂; simp [WTA.evalState_node]; (
  rw [ iInf_add_iInf_eq_iInf_prod ];
  convert ( Equiv.iInf_congr ( Equiv.arrowProdEquivProdArrow _ _ _ ) _ ) using 3;
  intro x; simp +decide [ ih, add_assoc, add_left_comm, add_comm ] ;
  simp +decide [ WTA.product, Finset.sum_add_distrib, add_assoc, add_left_comm, add_comm ];
  ring!);

/-
**Tropical product closure**: The product automaton computes the pointwise
    tropical product (i.e., sum of costs) of the component semantics.
-/
theorem WTA.eval_product {Q₁ Q₂ : Type*}
    (A₁ : WTA σ ar Q₁) (A₂ : WTA σ ar Q₂)
    (t : RTree σ ar) :
    (A₁.product A₂).eval t = A₁.eval t + A₂.eval t := by
  convert iInf_add_iInf_eq_iInf_prod ( fun q => A₁.evalState t q + A₁.finalCost q ) ( fun q => A₂.evalState t q + A₂.finalCost q ) |> Eq.symm using 1;
  refine' le_antisymm _ _;
  · refine' le_iInf fun p => _;
    refine' le_trans ( ciInf_le _ p ) _;
    · exact ⟨ 0, Set.forall_mem_range.2 fun q => zero_le _ ⟩;
    · rw [ WTA.evalState_product ];
      exact le_of_eq ( by rw [ WTA.product ] ; ring );
  · refine' le_iInf fun q => _;
    refine' le_trans ( ciInf_le _ q ) _;
    · exact ⟨ 0, Set.forall_mem_range.2 fun p => zero_le _ ⟩;
    · rw [ WTA.evalState_product ];
      unfold WTA.product; simp +decide [ add_assoc, add_comm, add_left_comm ] ;

/-! ## Union Automaton -/

/-- The union automaton of two WTAs. State space is the disjoint sum `Q₁ ⊕ Q₂`.
    Transitions only allow homogeneous child states: all children must be from the
    same component. Mixed assignments receive cost `⊤` (impossible).
    This realizes the tropical sum (pointwise infimum) of the two tree series. -/
noncomputable def WTA.union {Q₁ Q₂ : Type*}
    (A₁ : WTA σ ar Q₁) (A₂ : WTA σ ar Q₂) :
    WTA σ ar (Q₁ ⊕ Q₂) where
  delta a f q := match q with
    | .inl q₁ =>
      if h : ∀ i, (f i).isLeft = true then
        A₁.delta a (fun i => (f i).getLeft (h i)) q₁
      else ⊤
    | .inr q₂ =>
      if h : ∀ i, (f i).isRight = true then
        A₂.delta a (fun i => (f i).getRight (h i)) q₂
      else ⊤
  finalCost q := match q with
    | .inl q₁ => A₁.finalCost q₁
    | .inr q₂ => A₂.finalCost q₂

/-! ### Union Theorems -/

/-
The union automaton preserves the left component's semantics.
-/
theorem WTA.evalState_union_inl {Q₁ Q₂ : Type*}
    (A₁ : WTA σ ar Q₁) (A₂ : WTA σ ar Q₂)
    (t : RTree σ ar) (q₁ : Q₁) :
    (A₁.union A₂).evalState t (Sum.inl q₁) = A₁.evalState t q₁ := by
  induction' t with a children ih generalizing q₁;
  -- By definition of union, the delta function for the inl case is the same as the delta function for A₁.
  have h_delta_inl : ∀ (f : Fin (ar a) → Q₁ ⊕ Q₂) (q₁ : Q₁), (A₁.union A₂).delta a f (Sum.inl q₁) = if h : ∀ i, (f i).isLeft = true then A₁.delta a (fun i => (f i).getLeft (h i)) q₁ else ⊤ :=
    fun _ _ => rfl;
  simp +decide only [evalState, h_delta_inl];
  refine' le_antisymm _ _;
  · refine' le_iInf fun f => _;
    refine' le_trans ( ciInf_le _ ( Sum.inl ∘ f ) ) _;
    · exact ⟨ 0, Set.forall_mem_range.2 fun f => zero_le _ ⟩;
    · aesop;
  · refine' le_iInf fun f => _;
    split_ifs with h;
    · refine' le_trans ( ciInf_le _ _ ) _;
      exact ⟨ 0, Set.forall_mem_range.2 fun _ => zero_le _ ⟩;
      exact fun i => ( f i ).getLeft ( h i );
      grind +suggestions;
    · exact le_add_of_le_of_nonneg ( le_top ) ( zero_le _ )

/-
The union automaton preserves the right component's semantics.
-/
theorem WTA.evalState_union_inr {Q₁ Q₂ : Type*}
    (A₁ : WTA σ ar Q₁) (A₂ : WTA σ ar Q₂)
    (t : RTree σ ar) (q₂ : Q₂) :
    (A₁.union A₂).evalState t (Sum.inr q₂) = A₂.evalState t q₂ := by
  induction' t with a children ih generalizing q₂;
  -- By definition of union, the transition cost for inr q₂ is A₂.delta a (fun i => (f i).getRight (h i)) q₂ if all children are inr, otherwise it's ⊤.
  have h_union_delta : ∀ f : Fin (ar a) → Q₁ ⊕ Q₂, (A₁.union A₂).delta a f (Sum.inr q₂) = if h : ∀ i, (f i).isRight = true then A₂.delta a (fun i => (f i).getRight (h i)) q₂ else ⊤ :=
    fun _ => rfl;
  rw [ WTA.evalState_node, WTA.evalState_node ];
  refine' le_antisymm _ _;
  · refine' le_iInf fun f => _;
    refine' le_trans ( iInf_le _ ( Sum.inr ∘ f ) ) _;
    aesop;
  · refine' le_iInf fun f => _;
    by_cases h : ∀ i, ( f i ).isRight = true <;> simp +decide [ h, h_union_delta ];
    refine' le_trans ( ciInf_le _ _ ) _;
    exact ⟨ 0, Set.forall_mem_range.2 fun _ => zero_le _ ⟩;
    exact fun i => ( f i ).getRight ( h i );
    grind

/-
**Tropical union closure**: The union automaton computes the pointwise
    tropical sum (i.e., infimum) of the component semantics.
-/
theorem WTA.eval_union {Q₁ Q₂ : Type*}
    (A₁ : WTA σ ar Q₁) (A₂ : WTA σ ar Q₂)
    (t : RTree σ ar) :
    (A₁.union A₂).eval t = A₁.eval t ⊓ A₂.eval t := by
  apply le_antisymm;
  · refine' le_min _ _;
    · refine' le_iInf fun q₁ => _;
      refine' le_trans ( ciInf_le _ ( Sum.inl q₁ ) ) _;
      · exact ⟨ 0, Set.forall_mem_range.2 fun q => zero_le _ ⟩;
      · rw [ WTA.evalState_union_inl, WTA.union ];
    · refine' le_iInf fun q₂ => _;
      refine' le_trans ( ciInf_le _ ( Sum.inr q₂ ) ) _;
      · exact ⟨ 0, Set.forall_mem_range.2 fun q => zero_le _ ⟩;
      · rw [ WTA.evalState_union_inr, WTA.union ];
  · simp +decide [ WTA.eval, WTA.evalState_union_inl, WTA.evalState_union_inr ];
    exact ⟨ fun a => Or.inl <| ciInf_le ⟨ 0, Set.forall_mem_range.2 fun _ => zero_le _ ⟩ _, fun b => Or.inr <| ciInf_le ⟨ 0, Set.forall_mem_range.2 fun _ => zero_le _ ⟩ _ ⟩

/-! ## State Complexity Bounds -/

/-
The product automaton has exactly `|Q₁| * |Q₂|` states.
-/
theorem card_product_states (Q₁ Q₂ : Type*) [Fintype Q₁] [Fintype Q₂] :
    Fintype.card (Q₁ × Q₂) = Fintype.card Q₁ * Fintype.card Q₂ := by
  convert Fintype.card_prod Q₁ Q₂

/-
The union automaton has exactly `|Q₁| + |Q₂|` states.
-/
theorem card_union_states (Q₁ Q₂ : Type*) [Fintype Q₁] [Fintype Q₂] :
    Fintype.card (Q₁ ⊕ Q₂) = Fintype.card Q₁ + Fintype.card Q₂ := by
  convert Fintype.card_sum

/-! ## Finite Family Closure -/

universe v in
/-- **Finite family closure**: For any nonempty finite family of weighted tree
    automata over a common state space, there exists an automaton whose
    semantics is the pointwise infimum of the family. This is the compositional
    theorem needed for dynamic programming and parser combination.

    Proved by iterated binary union: the union automaton at each step has
    state space `Q ⊕ R` where `R` is the state space of the previously
    constructed automaton. -/
theorem WTA.eval_finset_inf_exists
    {ι : Type*} [DecidableEq ι]
    {I : Finset ι} (hI : I.Nonempty)
    {Q : Type v}
    (A : ι → WTA σ ar Q) :
    ∃ (R : Type v), ∃ B : WTA σ ar R,
      ∀ t, B.eval t = I.inf' hI (fun i => (A i).eval t) := by
  induction I using Finset.cons_induction with
  | empty => exact absurd hI (by simp)
  | cons a s ha ih =>
    by_cases hs : s.Nonempty
    · obtain ⟨R, B, hB⟩ := ih hs
      exact ⟨Q ⊕ R, (A a).union B, fun t => by
        simp only [WTA.eval_union, hB, Finset.inf'_cons hs]⟩
    · have hs_eq : s = ∅ := Finset.not_nonempty_iff_eq_empty.mp hs
      subst hs_eq
      exact ⟨Q, A a, fun t => by simp [Finset.inf'_singleton]⟩

/-! ## Monotonicity -/

/-
Product construction is monotone: if both components have smaller eval,
    so does the product.
-/
theorem WTA.eval_product_le {Q₁ Q₂ : Type*}
    (A₁ A₁' : WTA σ ar Q₁) (A₂ A₂' : WTA σ ar Q₂)
    (h₁ : ∀ t, A₁.eval t ≤ A₁'.eval t)
    (h₂ : ∀ t, A₂.eval t ≤ A₂'.eval t)
    (t : RTree σ ar) :
    (A₁.product A₂).eval t ≤ (A₁'.product A₂').eval t := by
  rw [ WTA.eval_product, WTA.eval_product ];
  exact add_le_add ( h₁ t ) ( h₂ t )

end TreeAutomata