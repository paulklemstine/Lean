import Mathlib

/-!
# A bridge between graph connectivity and the block-graphon `Lᵖ` functional

This file proves a cross-domain "connector" theorem linking two a priori unrelated
objects:

* **Graph theory / topology of graphs.** The number of *connected components* of a
  finite simple graph `G`, i.e. `Fintype.card G.ConnectedComponent`.

* **Analysis / spectral combinatorics.** The homomorphism-type functional
  `∑_φ ∏_{(a,b) : G.Adj a b} W(φ a, φ b)` evaluated on a *block-diagonal kernel*
  `W`, the discrete analogue of the `Lᵖ` graphon functional
  `‖W_F‖_{Lᵖ}` appearing in the KNRS / Sidorenko circle of questions.

The heart of the bridge is a clean bijection:

> A function `V → β` that is constant on every edge of `G` is *the same thing* as
> an arbitrary function `G.ConnectedComponent → β`.

This is `edgeConstEquiv`, and counting its two sides gives

> `#{ f : V → β // f constant on edges } = (card β) ^ (number of components)`

(`card_edgeConst`).  Feeding this counting identity into the block-diagonal
homomorphism functional yields the closed form

> `∑_φ homProd (block t) φ = t ^ (#directed edges) · k ^ (#components)`

(`blockHomSum`).  This is exactly the combinatorial mechanism ("counting
monochromatic vertex colourings `= k^c`") behind the `k^{c - n + m·p} ρ^{m·p}`
value of the block-kernel `Lᵖ` functional: the exponent of `k` is the number of
connected components `c`, and it is precisely this component count — a graph
invariant — that governs the analytic size of the functional.

All statements are fully finite and rigorous; no `sorry`, no extra axioms.
-/

namespace GraphComponentColoringBridge

open SimpleGraph Finset

variable {V : Type*} (G : SimpleGraph V)

/-- A function that is constant on every edge is constant along every walk. -/
theorem const_on_walk {β : Type*} {f : V → β} (hf : ∀ a b, G.Adj a b → f a = f b) :
    ∀ {v w : V}, G.Walk v w → f v = f w := by
  intro v w p
  induction p with
  | nil => rfl
  | cons hadj q ih => exact (hf _ _ hadj).trans ih

/-- **The connector bijection.**  Functions `V → β` that are constant on every edge
of `G` are in canonical bijection with functions `G.ConnectedComponent → β`.  This
identifies a purely combinatorial constraint (respect adjacency) with an
unconstrained map out of the component quotient. -/
def edgeConstEquiv (β : Type*) :
    {f : V → β // ∀ a b, G.Adj a b → f a = f b} ≃ (G.ConnectedComponent → β) where
  toFun := fun f => ConnectedComponent.lift f.1 (fun v w p _ => const_on_walk G f.2 p)
  invFun := fun g => ⟨fun v => g (G.connectedComponentMk v), by
    intro a b h; exact congrArg g ((ConnectedComponent.eq).2 h.reachable)⟩
  left_inv := by intro f; ext v; simp [ConnectedComponent.lift_mk]
  right_inv := by
    intro g; ext c
    induction c using ConnectedComponent.ind with
    | _ v => simp [ConnectedComponent.lift_mk]

/-- **Counting form of the bridge.**  The number of `β`-colourings of the vertices
that are constant on each edge equals `(card β)` raised to the number of connected
components.  Graph connectivity on the right, an analytic/counting quantity on the
left. -/
theorem card_edgeConst (β : Type*) [Fintype V] [Fintype β]
    [Fintype G.ConnectedComponent] :
    Nat.card {f : V → β // ∀ a b, G.Adj a b → f a = f b}
      = Fintype.card β ^ Fintype.card G.ConnectedComponent := by
  rw [Nat.card_congr (edgeConstEquiv G β), Nat.card_fun,
    Nat.card_eq_fintype_card, Nat.card_eq_fintype_card]

variable [Fintype V] [DecidableEq V] [DecidableRel G.Adj]

/-- The discrete homomorphism functional: product of a kernel `Wk` over all directed
edges of `G` (a factor of `1` on non-edges).  This is the finite step-graphon
analogue of `∏_{edges} W(φ a, φ b)`. -/
noncomputable def homProd {k : ℕ} (Wk : Fin k → Fin k → ℝ) (φ : V → Fin k) : ℝ :=
  ∏ a : V, ∏ b : V, (if G.Adj a b then Wk (φ a) (φ b) else 1)

/-- The number of directed edges (ordered adjacent pairs) of `G`. -/
noncomputable def dirEdgeCard : ℕ := (univ.filter (fun p : V × V => G.Adj p.1 p.2)).card

omit [DecidableEq V] in
/-- On a block-diagonal kernel `bk t = (fun i j => if i = j then t else 0)`, the
homomorphism product collapses to an indicator: it is `t ^ (#directed edges)` when
`φ` is constant on every edge, and `0` otherwise. -/
theorem homProd_block_eq {k : ℕ} (t : ℝ) (φ : V → Fin k) :
    homProd G (fun i j => if i = j then t else 0) φ
      = if (∀ a b, G.Adj a b → φ a = φ b) then t ^ (dirEdgeCard G) else 0 := by
  split_ifs with h;
  · have : homProd G (fun i j => if i = j then t else 0) φ = ∏ a : V, ∏ b : V, (if G.Adj a b then t else 1) := by
      grind +locals;
    rw [ this, ← Finset.prod_product' ];
    simp +decide [ Finset.prod_ite, dirEdgeCard ];
  · unfold homProd; simp_all +decide [ Finset.prod_eq_zero_iff ] ;
    exact ⟨ h.choose, h.choose_spec.choose, by rw [ if_pos h.choose_spec.choose_spec.1, if_neg h.choose_spec.choose_spec.2 ] ⟩

/-- **Analytic form of the bridge (block-kernel closed form).**  Summing the
block-diagonal homomorphism functional over all `k`-colourings factors as
`t ^ (#directed edges) · k ^ (#connected components)`.  The exponent of `k` is the
graph's component count: this is the combinatorial engine behind the block-graphon
`Lᵖ` value `k^{c - n + m p} ρ^{m p}`. -/
theorem blockHomSum {k : ℕ} [Fintype G.ConnectedComponent] (t : ℝ) :
    ∑ φ : V → Fin k, homProd G (fun i j => if i = j then t else 0) φ
      = t ^ (dirEdgeCard G) * (k : ℝ) ^ (Fintype.card G.ConnectedComponent) := by
  rw [ Finset.sum_congr rfl fun φ _ => homProd_block_eq G t φ ];
  convert congr_arg ( fun x : ℕ => ( t ^ dirEdgeCard G : ℝ ) * x ) ( card_edgeConst G ( Fin k ) ) using 1;
  · simp +decide [ Finset.sum_ite, mul_comm, Fintype.card_subtype ];
  · simp +decide

end GraphComponentColoringBridge