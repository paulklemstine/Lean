/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The odd-clique obstruction for conformability of odd-order regular graphs

This file formalizes the *combinatorial backbone* of the conformability problem that
underlies the NP-completeness reductions for connected `d`-regular graphs of odd order
with bounded independence number `α(G) = k`.

## Mathematical setting

For a graph `G` of order `n` with maximum degree `Δ`, the *deficiency* is
`def(G) = Σ_v (Δ - d(v))`, which is `0` for `Δ`-regular graphs.  A proper vertex
colouring with `Δ + 1` colours is **conformable** when the number of colour classes
whose cardinality has parity different from `n` is at most `def(G)`.  For a `d`-regular
graph (so `Δ = d`, `def(G) = 0`) this forces **every** colour class to have the same
parity as `n`.

When `n` is odd, every one of the `d + 1` colour classes must therefore have **odd**
cardinality.  Each colour class is an independent set of `G`, equivalently a clique of
the complement `Gᶜ` (whose clique number is `α(G) = k`).  Hence the classes are exactly
*cliques of odd size at most `k` in the complement* — the structure the reductions
encode.

## Main results

* `conformable_odd_order_bound` — the odd-clique counting obstruction:
  `n ≤ (d + 1) · oddCap α`, where `oddCap α` is the largest odd number `≤ α`.  Because
  classes must be odd, the effective per-class cap is `oddCap α`, not `α`; when `α` is
  even this strictly improves the naive bound `n ≤ (d+1)·α`.
* `conformable_odd_order_even_degree` — a conformable odd-order graph forces `d` even.
* `conformable_regular_odd_order_bound` — the same bound phrased for `Δ + 1` colours of a
  genuinely `d`-regular graph (regularity is used through `regular_maxDegree_eq`).
* `no_conformable_of_card_gt` — contrapositive obstruction: a proper colouring of an
  odd-order graph with `(d+1)·oddCap α < n` can never be conformable.
* `fiber_compl_clique` — each colour class is a clique of the complement graph.
* `triangle_conformable` — a positive witness (`K₃`) showing the hypotheses are jointly
  satisfiable and the bound `n ≤ (d+1)·oddCap α` is tight.
-/
import Mathlib

namespace Catalog.Algebra.Conformability

open SimpleGraph Finset

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): conformability of a `d`-regular graph of ODD order is
--   governed by a parity-constrained packing of independent sets.  Because every one of
--   the `d+1` colour classes must be odd-sized, the binding cap per class is the largest
--   ODD number `≤ α(G)`, not `α(G)` itself.  Conjecture: `n ≤ (d+1)·oddCap(α)`, strictly
--   stronger than `n ≤ (d+1)·α` when `α` is even.
-- Experiment (Experimenter): partition `V` into the `d+1` colour fibres; sum their
--   cardinalities (`card_eq_sum_card_fiberwise`); use the conformable parity hypothesis
--   to force each fibre odd, and properness to force each fibre independent, hence
--   `≤ oddCap α`; sum the bound.  A separate `mod 2` computation yields `d` even.
-- !-- End Lab Notes -- !--

/-- The largest odd natural number that is `≤ a` (and `0` when `a = 0`).
    This is the per-class cap forced by the odd-order conformability constraint. -/
def oddCap (a : ℕ) : ℕ := if Odd a then a else a - 1

/-- An odd number bounded by `a` is bounded by `oddCap a`: when `a` is even the parity
    gap shaves off one unit. -/
lemma odd_le_oddCap {x a : ℕ} (hx : Odd x) (hxa : x ≤ a) : x ≤ oddCap a := by
  unfold oddCap
  by_cases h : Odd a
  · simp [h]; exact hxa
  · simp [h]
    rw [Nat.not_odd_iff_even] at h
    obtain ⟨k, hk⟩ := hx
    obtain ⟨m, hm⟩ := h
    omega

variable {V : Type*} [Fintype V]

/-- Each colour class (fibre of a proper colouring) is an independent set of `G`. -/
lemma fiber_indep (G : SimpleGraph V) [DecidableRel G.Adj] {d : ℕ}
    (c : V → Fin (d + 1)) (hproper : ∀ ⦃u v⦄, G.Adj u v → c u ≠ c v) (i : Fin (d + 1)) :
    G.IsIndepSet ↑(univ.filter (fun v => c v = i)) := by
  intro u hu v hv _ hadj
  simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_univ, true_and] at hu hv
  exact hproper hadj (by rw [hu, hv])

/-- Each colour class is a **clique of the complement** `Gᶜ`: this is the bridge to the
    "cliques of odd size up to `k` in the complement" description of conformable classes,
    since `α(G)` is the clique number of `Gᶜ`. -/
lemma fiber_compl_clique (G : SimpleGraph V) [DecidableRel G.Adj] {d : ℕ}
    (c : V → Fin (d + 1)) (hproper : ∀ ⦃u v⦄, G.Adj u v → c u ≠ c v) (i : Fin (d + 1)) :
    Gᶜ.IsClique ↑(univ.filter (fun v => c v = i)) := by
  rw [SimpleGraph.isClique_compl]
  exact fiber_indep G c hproper i

/-- **Odd-clique counting obstruction.**  If a graph of *odd* order `n` whose independent
    sets all have size `≤ α` admits a conformable proper colouring with `d + 1` colours
    (every colour class of parity equal to `n`, i.e. odd), then
    `n ≤ (d + 1) · oddCap α`.

    The strength over the naive `n ≤ (d+1)·α` is the `oddCap`: each colour class is an
    odd-sized clique of the complement, so its size is at most the largest odd number
    not exceeding `α`. -/
theorem conformable_odd_order_bound (G : SimpleGraph V) [DecidableRel G.Adj]
    {d α : ℕ} (c : V → Fin (d + 1))
    (hproper : ∀ ⦃u v⦄, G.Adj u v → c u ≠ c v)
    (hα : ∀ s : Finset V, G.IsIndepSet ↑s → s.card ≤ α)
    (hodd : Odd (Fintype.card V))
    (hconf : ∀ i : Fin (d + 1),
      (univ.filter (fun v => c v = i)).card % 2 = Fintype.card V % 2) :
    Fintype.card V ≤ (d + 1) * oddCap α := by
  have hsum : Fintype.card V = ∑ i : Fin (d + 1), (univ.filter (fun v => c v = i)).card := by
    rw [← Finset.card_univ]
    exact Finset.card_eq_sum_card_fiberwise (fun x _ => Finset.mem_coe.mpr (mem_univ _))
  have hn1 : Fintype.card V % 2 = 1 := Nat.odd_iff.mp hodd
  have hterm : ∀ i : Fin (d + 1), (univ.filter (fun v => c v = i)).card ≤ oddCap α := by
    intro i
    have hodd_i : Odd (univ.filter (fun v => c v = i)).card := by
      rw [Nat.odd_iff, hconf i, hn1]
    have hle : (univ.filter (fun v => c v = i)).card ≤ α :=
      hα _ (fiber_indep G c hproper i)
    exact odd_le_oddCap hodd_i hle
  calc Fintype.card V = ∑ i : Fin (d + 1), (univ.filter (fun v => c v = i)).card := hsum
    _ ≤ ∑ _i : Fin (d + 1), oddCap α := Finset.sum_le_sum (fun i _ => hterm i)
    _ = (d + 1) * oddCap α := by
        rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin]; ring

/-- **Parity obstruction.**  A conformable colouring of an odd-order graph with `d + 1`
    colours forces the degree `d` to be even: the `d + 1` odd class sizes sum to the odd
    number `n`, so `d + 1` is odd. -/
theorem conformable_odd_order_even_degree (G : SimpleGraph V) [DecidableRel G.Adj]
    {d : ℕ} (c : V → Fin (d + 1))
    (hodd : Odd (Fintype.card V))
    (hconf : ∀ i : Fin (d + 1),
      (univ.filter (fun v => c v = i)).card % 2 = Fintype.card V % 2) :
    Even d := by
  have hsum : Fintype.card V = ∑ i : Fin (d + 1), (univ.filter (fun v => c v = i)).card := by
    rw [← Finset.card_univ]
    exact Finset.card_eq_sum_card_fiberwise (fun x _ => Finset.mem_coe.mpr (mem_univ _))
  have hn1 : Fintype.card V % 2 = 1 := Nat.odd_iff.mp hodd
  have key : Fintype.card V % 2 = (d + 1) % 2 := by
    conv_lhs => rw [hsum]
    rw [Finset.sum_nat_mod]
    have hone : ∀ i : Fin (d + 1), (univ.filter (fun v => c v = i)).card % 2 = 1 := by
      intro i; rw [hconf i, hn1]
    rw [Finset.sum_congr rfl (fun i _ => hone i)]
    simp [Finset.sum_const, Finset.card_univ]
  rw [hn1] at key
  rw [Nat.even_iff]
  omega

/-- **Contrapositive obstruction.**  If `(d + 1) · oddCap α < n` then *no* proper colouring
    with `d + 1` colours of an odd-order graph (independence `≤ α`) can be conformable. -/
theorem no_conformable_of_card_gt (G : SimpleGraph V) [DecidableRel G.Adj]
    {d α : ℕ} (c : V → Fin (d + 1))
    (hproper : ∀ ⦃u v⦄, G.Adj u v → c u ≠ c v)
    (hα : ∀ s : Finset V, G.IsIndepSet ↑s → s.card ≤ α)
    (hodd : Odd (Fintype.card V))
    (hgt : (d + 1) * oddCap α < Fintype.card V) :
    ¬ (∀ i : Fin (d + 1),
        (univ.filter (fun v => c v = i)).card % 2 = Fintype.card V % 2) := by
  intro hconf
  have := conformable_odd_order_bound G c hproper hα hodd hconf
  omega

/-- For a nonempty `d`-regular graph the maximum degree is `d`. -/
lemma regular_maxDegree_eq (G : SimpleGraph V) [DecidableRel G.Adj] [Nonempty V] {d : ℕ}
    (h : G.IsRegularOfDegree d) : G.maxDegree = d := by
  apply le_antisymm
  · apply SimpleGraph.maxDegree_le_of_forall_degree_le
    intro v; rw [h v]
  · obtain ⟨v⟩ := ‹Nonempty V›
    calc d = G.degree v := (h v).symm
      _ ≤ G.maxDegree := degree_le_maxDegree G v

/-- **Regular-graph form.**  For a genuinely `d`-regular graph the conformable setting uses
    `Δ + 1 = maxDegree + 1` colours; regularity (`regular_maxDegree_eq`) identifies this
    palette with `d + 1`, giving the odd-clique bound `n ≤ (d + 1) · oddCap α`. -/
theorem conformable_regular_odd_order_bound (G : SimpleGraph V) [DecidableRel G.Adj]
    [Nonempty V] {d α : ℕ} (hreg : G.IsRegularOfDegree d)
    (c : V → Fin (G.maxDegree + 1))
    (hproper : ∀ ⦃u v⦄, G.Adj u v → c u ≠ c v)
    (hα : ∀ s : Finset V, G.IsIndepSet ↑s → s.card ≤ α)
    (hodd : Odd (Fintype.card V))
    (hconf : ∀ i : Fin (G.maxDegree + 1),
      (univ.filter (fun v => c v = i)).card % 2 = Fintype.card V % 2) :
    Fintype.card V ≤ (d + 1) * oddCap α := by
  have hbound := conformable_odd_order_bound G c hproper hα hodd hconf
  rwa [regular_maxDegree_eq G hreg] at hbound

-- !-- Lab Notes -- !--
-- Analysis (Analyst):
--   * SURVIVED: `conformable_odd_order_bound` (the `oddCap` refinement), the parity
--     theorem `conformable_odd_order_even_degree`, the complement-clique bridge
--     `fiber_compl_clique`, and the regular-graph specialization.  These capture exactly
--     why the reduction must pack ODD cliques of the complement: the parity of `n` and
--     the deficiency-zero condition jointly force every class odd.
--   * "TRUE BUT HARD" (left informal): the full NP-completeness statement.  Encoding a
--     Turing/SAT reduction and the polynomial-time machinery is far beyond a self-
--     contained Lean file; we instead formalize the invariant the reduction relies on.
--   * STRUCTURAL PATTERN: the binding constraint is `oddCap α`, not `α`.  When `α` is
--     even, `oddCap α = α - 1`, so the obstruction is strictly sharper — this is the
--     parity slack that the hardness construction exploits.
-- Critique (Critic): none of the main theorems is vacuous.  `triangle_conformable`
--   below exhibits a model satisfying every hypothesis with the bound TIGHT (`3 = 3·1`),
--   so the inequality is not provable by weakening.  The proofs use genuine arguments
--   (`card_eq_sum_card_fiberwise`, parity via `sum_nat_mod`, `omega`), not `decide`.
-- !-- End Lab Notes -- !--

/-! ### Positive witness: the triangle `K₃`

`K₃ = (⊤ : SimpleGraph (Fin 3))` is `2`-regular of odd order `3` with `α = 1`.  Colouring
each vertex its own colour gives three singleton (odd) classes, so it is conformable, and
the bound `n ≤ (d + 1) · oddCap α` reads `3 ≤ 3 · 1`, i.e. is tight. -/
theorem triangle_conformable :
    ∃ c : Fin 3 → Fin (2 + 1),
      (∀ ⦃u v : Fin 3⦄, (⊤ : SimpleGraph (Fin 3)).Adj u v → c u ≠ c v) ∧
      (∀ s : Finset (Fin 3), (⊤ : SimpleGraph (Fin 3)).IsIndepSet ↑s → s.card ≤ 1) ∧
      Odd (Fintype.card (Fin 3)) ∧
      (∀ i : Fin (2 + 1),
        (univ.filter (fun v => (id : Fin 3 → Fin 3) v = i)).card % 2
          = Fintype.card (Fin 3) % 2) := by
  refine ⟨id, ?_, ?_, ?_, ?_⟩
  · intro u v h; simpa using h
  · intro s hs
    by_contra h
    push_neg at h
    obtain ⟨a, ha, b, hb, hab⟩ := Finset.one_lt_card.mp h
    exact (hs ha hb hab) (by simp [SimpleGraph.top_adj, hab])
  · decide
  · intro i
    have : (univ.filter (fun v : Fin 3 => (id : Fin 3 → Fin 3) v = i)) = {i} := by
      ext v; simp [eq_comm]
    rw [this]; simp

/-- The triangle witness makes the odd-clique bound tight: `n = (d + 1) · oddCap α`. -/
theorem triangle_bound_tight : Fintype.card (Fin 3) = (2 + 1) * oddCap 1 := by
  simp [oddCap]

-- !-- Lab Notes -- !--
-- Synthesis (PI): conformability of an odd-order `d`-regular graph is an
--   ODD-CLIQUE PARTITION problem on the complement: partition `V` into `d+1` cliques of
--   `Gᶜ`, each of ODD size `≤ α(G)`.  The parity constraint forces `d` even and caps each
--   class at `oddCap α`, the engine behind the per-`k` packing reductions.  The triangle
--   shows the bound is achieved; `oddCap` is exactly the quantitative slack that grows
--   with the independence number `k`.
-- !-- End Lab Notes -- !--

end Catalog.Algebra.Conformability