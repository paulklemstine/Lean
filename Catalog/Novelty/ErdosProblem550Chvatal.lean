/-
# Erdős Problem 550 — the all-ones (Chvátal) case: lower bound

Erdős Problem 550 conjectures that for fixed `k ≥ 2` and `1 ≤ m₁ ≤ ⋯ ≤ m_k`,
for all sufficiently large `n` and every `n`-vertex tree `T`,
`R(T, K_{m₁,…,m_k}) ≤ (k-1)(R(T, K_{m₁,m₂}) - 1) + m₁`.

The **all-ones special case** `m₁ = ⋯ = m_k = 1` is especially clean: the complete
multipartite graph with every part of size one is the complete graph `K_k`, and
`R(T, K_{1,1}) = R(T, K₂) = n` (a single blue edge is avoided only by an all-red
colouring, i.e. a complete graph, which contains the `n`-vertex tree iff it has
`≥ n` vertices).  The conjectured bound then reads

  `R(T, K_k) ≤ (k-1)(n-1) + 1`,

which is exactly **Chvátal's theorem** `R(T_n, K_k) = (k-1)(n-1) + 1`.

This file proves the **lower bound** half of Chvátal's theorem, i.e. that the
Erdős–550 bound is *tight* for the all-ones case:

  `R(T, K_k) > (k-1)(n-1)`,

witnessed by the extremal colouring whose red graph is a disjoint union of
`k-1` red cliques each on `n-1` vertices.

* No red copy of `T`: each red component has only `n-1 < n` vertices, while the
  tree `T` is connected on `n` vertices, so cannot be embedded.
* No blue copy of `K_k`: the blue graph is complete `(k-1)`-partite, so its
  cliques are transversals of at most `k-1` parts.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The Erdős–550 bound is tight; in the all-ones case the
  disjoint-clique colouring should witness `R(T,K_k) > (k-1)(n-1)`.
Experiment (Experimenter): Encode the extremal red graph as `blockGraph (k-1) (n-1)`
  on `Fin ((k-1)(n-1))`, with `Adj x y ↔ x ≠ y ∧ x/s = y/s`.  Show both monochromatic
  patterns are absent.
Analysis (Analyst): The "no red tree" direction is the substantive one: it needs that
  a graph homomorphism preserves reachability, so the connected tree lands inside a
  single block of size `n-1 < n`, contradicting injectivity.  The "no blue clique"
  direction is a pigeonhole on the `k-1` block indices.
Critique (Critic): The argument uses only connectivity of `T`, not acyclicity; we keep
  the `IsTree` hypothesis to stay faithful to the problem statement, but record that
  connectivity suffices (`chvatal_lower_bound_connected`).
Synthesis (PI): Lower bound proven for all `n, k`; pairs with the upper bound to pin
  down the all-ones case of Erdős 550.
-/

import Mathlib

open SimpleGraph

namespace Erdos550

/-- The two-colour "arrow" relation for general graph patterns:
`RamseyArrows N T H` holds when every red/blue colouring of the complete graph on
`Fin N` (encoded by its red subgraph `G`, blue being the complement `Gᶜ`) contains
a red copy of `T` or a blue copy of `H`. -/
def RamseyArrows (N : ℕ) {α β : Type} (T : SimpleGraph α) (H : SimpleGraph β) : Prop :=
  ∀ G : SimpleGraph (Fin N), T ⊑ G ∨ H ⊑ Gᶜ

/-- The extremal red graph: a disjoint union of `b` cliques, each on `s` vertices.
Two vertices of `Fin (b*s)` are adjacent iff they are distinct and lie in the same
block `⌊x/s⌋`. -/
def blockGraph (b s : ℕ) : SimpleGraph (Fin (b * s)) where
  Adj x y := x ≠ y ∧ x.val / s = y.val / s
  symm := by intro x y h; exact ⟨h.1.symm, h.2.symm⟩
  loopless := ⟨fun x h => h.1 rfl⟩

/-- The block index of a vertex. -/
def blk (b s : ℕ) (x : Fin (b * s)) : ℕ := x.val / s

/-- Adjacent vertices lie in the same block. -/
theorem blk_eq_of_adj (b s : ℕ) {x y : Fin (b * s)} (h : (blockGraph b s).Adj x y) :
    blk b s x = blk b s y := h.2

/-- Reachable vertices lie in the same block. -/
theorem blk_eq_of_reachable (b s : ℕ) {x y : Fin (b * s)}
    (h : (blockGraph b s).Reachable x y) : blk b s x = blk b s y := by
  obtain ⟨w⟩ := h
  induction w with
  | nil => rfl
  | cons hadj _ ih => exact hadj.2.trans ih

/-- Every block index is `< b` (vacuous when `b * s = 0`). -/
theorem blk_lt (b s : ℕ) (hs : 0 < s) (x : Fin (b * s)) : blk b s x < b := by
  have hx : x.val < b * s := x.isLt
  rw [blk, Nat.div_lt_iff_lt_mul hs]
  omega

/-
The fiber of `blk` over a fixed block index `c` has at most `s` vertices.
-/
theorem fiber_card_le (b s c : ℕ) :
    (Finset.univ.filter (fun x : Fin (b * s) => blk b s x = c)).card ≤ s := by
  by_contra h_contra;
  obtain ⟨x₁, x₂, hx₁, hx₂, hxs⟩ : ∃ x₁ x₂ : Fin (b * s), blk b s x₁ = c ∧ blk b s x₂ = c ∧ x₁ ≠ x₂ ∧ x₁.val % s = x₂.val % s := by
    by_contra! h_contra' ; simp_all +decide ;
    exact absurd ( Finset.card_le_card ( show Finset.image ( fun x : Fin ( b * s ) => ( x : ℕ ) % s ) ( Finset.filter ( fun x : Fin ( b * s ) => blk b s x = c ) Finset.univ ) ⊆ Finset.range s from Finset.image_subset_iff.2 fun x hx => Finset.mem_range.2 <| Nat.mod_lt _ <| Nat.pos_of_ne_zero <| by aesop_cat ) ) ( by rw [ Finset.card_image_of_injOn <| fun x hx y hy hxy => by contrapose! hxy; aesop ] ; simpa using h_contra );
  have h_eq : x₁.val = s * c + (x₁.val % s) ∧ x₂.val = s * c + (x₂.val % s) := by
    exact ⟨ by rw [ ← hx₁, blk ] ; rw [ Nat.div_add_mod ], by rw [ ← hx₂, blk ] ; rw [ Nat.div_add_mod ] ⟩;
  exact hxs.1 ( Fin.ext <| by linarith )

/-
**No red tree.**  A connected graph `T` on `n` vertices admits no copy inside
`blockGraph b s` when `s < n`: a hom preserves reachability, so the whole image
lands in a single block of size `≤ s`, contradicting injectivity.
-/
theorem no_red_connected {n b s : ℕ} (T : SimpleGraph (Fin n)) (hT : T.Connected)
    (hsn : s < n) : ¬ (T ⊑ blockGraph b s) := by
  rintro ⟨ f, hf ⟩;
  -- Since $T$ is connected, the image of $f$ is contained in a single block of $blockGraph b s$.
  have h_block : ∃ c : ℕ, ∀ x : Fin n, blk b s (f x) = c := by
    have h_block : ∀ x y : Fin n, (blockGraph b s).Reachable (f x) (f y) := by
      intro x y; have := hT x y; simp_all +decide [ SimpleGraph.Reachable ] ;
      exact ⟨ this.some.map f ⟩;
    exact ⟨ blk b s ( f ⟨ 0, by linarith ⟩ ), fun x => blk_eq_of_reachable b s ( h_block _ _ ) ⟩;
  obtain ⟨ c, hc ⟩ := h_block;
  have h_card : (Finset.univ.image f).card ≤ (Finset.univ.filter (fun x : Fin (b * s) => blk b s x = c)).card := by
    exact Finset.card_le_card fun x hx => by aesop;
  exact absurd h_card ( by rw [ Finset.card_image_of_injective _ hf ] ; simpa using by linarith [ fiber_card_le b s c ] )

/-
**No blue clique.**  The complete graph `K_k` on `k` vertices admits no copy
inside `(blockGraph b s)ᶜ` when `b < k`: such a copy would inject the `k` vertices
into the `b` block indices.
-/
theorem no_blue_clique {k b s : ℕ} (hbk : b < k) :
    ¬ ((⊤ : SimpleGraph (Fin k)) ⊑ (blockGraph b s)ᶜ) := by
  by_contra! h_contra;
  -- Let $f$ be the homomorphism from the complete graph on $k$ vertices to the complement of the block graph.
  obtain ⟨f, hf_inj, hf_hom⟩ : ∃ f : Fin k → Fin (b * s), Function.Injective f ∧ ∀ i j, i ≠ j → ¬(blockGraph b s).Adj (f i) (f j) := by
    obtain ⟨ f, hf ⟩ := h_contra;
    use f;
    exact ⟨ hf, fun i j hij h => by have := f.map_rel ( show ( ⊤ : SimpleGraph ( Fin k ) ).Adj i j from by aesop ) ; aesop ⟩;
  -- Consider the function $g : Fin k → Fin b$ defined by $g(i) = blk b s (f i)$.
  set g : Fin k → Fin b := fun i => ⟨blk b s (f i), by
    exact Nat.div_lt_of_lt_mul <| by linarith [ Fin.is_lt ( f i ) ] ;⟩
  generalize_proofs at *;
  exact absurd ( Fintype.card_le_of_injective g ( fun i j hij => Classical.not_not.1 fun hi => hf_hom i j hi <| by
    exact ⟨ hf_inj.ne hi, by aesop ⟩ ) ) ( by simpa using by linarith )

/-
**Lower bound for the all-ones case (connectivity form).**
For every connected graph `T` on `n` vertices and every `k ≥ 1`, the colouring
`blockGraph (k-1) (n-1)` of `K_{(k-1)(n-1)}` has neither a red `T` nor a blue
`K_k`, hence `¬ RamseyArrows ((k-1)(n-1)) T K_k`.
-/
theorem chvatal_lower_bound_connected {n : ℕ} (T : SimpleGraph (Fin n))
    (hT : T.Connected) {k : ℕ} (hk : 1 ≤ k) :
    ¬ RamseyArrows ((k - 1) * (n - 1)) T (⊤ : SimpleGraph (Fin k)) := by
  obtain a | a := Nat.eq_zero_or_pos n <;> simp_all +decide;
  · cases n <;> simp_all +decide [ SimpleGraph.connected_iff_exists_forall_reachable ];
  · intro h;
    convert no_red_connected T hT ( Nat.sub_lt a zero_lt_one ) <| h _ |> Or.resolve_right <| no_blue_clique <| Nat.sub_lt hk zero_lt_one

/-- **Chvátal lower bound (tree form).**  For every `n`-vertex tree `T` and every
`k ≥ 1`, `R(T, K_k) > (k-1)(n-1)`; equivalently `¬ RamseyArrows ((k-1)(n-1)) T K_k`.
This is the lower-bound half of the all-ones case of Erdős Problem 550, witnessing
that the conjectured bound is tight. -/
theorem chvatal_lower_bound {n : ℕ} (T : SimpleGraph (Fin n)) (hT : T.IsTree)
    {k : ℕ} (hk : 1 ≤ k) :
    ¬ RamseyArrows ((k - 1) * (n - 1)) T (⊤ : SimpleGraph (Fin k)) :=
  chvatal_lower_bound_connected T hT.isConnected hk

end Erdos550