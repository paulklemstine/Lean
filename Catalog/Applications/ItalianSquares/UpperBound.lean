import Applications.ItalianSquares.Defs

/-!
# The `n - 1` upper bound for mutually orthogonal Italian squares

Main result: any family of pairwise orthogonal Italian squares on a symbol set with
at least two elements has at most `#α - 1` members.

-- !-- Lab Notes -- !--
Experiment (Experimenter): the textbook proof "standardizes" each square so its
first row is the identity, then reads off distinct values in cell (1,0).  We avoid
constructing standardized squares explicitly.  For each square `Lₜ` let `row₀` be
the (bijective) map `j ↦ Lₜ x₀ j`; set `a t := row₀⁻¹ (Lₜ x₁ x₀)`, i.e. the column
where row `x₀` carries the symbol that sits in cell `(x₁, x₀)`.  So
`Lₜ x₀ (a t) = Lₜ x₁ x₀`.

Analysis:
* `a t ≠ x₀`: otherwise `Lₜ x₀ x₀ = Lₜ x₁ x₀`, contradicting injectivity of column
  `x₀` at the distinct rows `x₀ ≠ x₁`.
* `a` is injective: if `a s = a t = a`, then `Lₛ x₀ a = Lₛ x₁ x₀` and
  `Lₜ x₀ a = Lₜ x₁ x₀`, so the superposition map of `Lₛ, Lₜ` agrees on cells
  `(x₁, x₀)` and `(x₀, a)`; orthogonality forces `(x₁, x₀) = (x₀, a)`, hence
  `x₁ = x₀`, a contradiction.
Thus `a` injects the index set into `α \ {x₀}`, giving `#K ≤ #α - 1`.

Critique (Critic): the bound needs `2 ≤ #α` (so two distinct rows `x₀ ≠ x₁` exist).
For `#α ≤ 1` orthogonality is vacuous/degenerate; we therefore hypothesize
`2 ≤ #α`, matching `n ≥ 2` in the statement of the problem.
-/

namespace ItalianSquares

open Function

/-- Helper: for an Italian square, the column map `i ↦ L i j` is injective. -/
lemma col_injective {α : Type*} (L : ItalianSquare α) (j : α) :
    Injective (fun i => L.toFun i j) :=
  (L.col_bij j).injective

/-- Helper: for an Italian square, the row map `j ↦ L i j` is bijective. -/
lemma row_bijective {α : Type*} (L : ItalianSquare α) (i : α) :
    Bijective (L.toFun i) :=
  L.row_bij i

/-
**Upper bound on mutually orthogonal Italian squares.**
A family `L : K → ItalianSquare α` that is pairwise orthogonal, over a symbol set
with at least two symbols, has at most `#α - 1` members.
-/
theorem card_le_card_sub_one {α : Type*} [Fintype α] [DecidableEq α]
    (hα : 2 ≤ Fintype.card α) {K : Type*} [Fintype K]
    (L : K → ItalianSquare α)
    (horth : ∀ s t, s ≠ t → Orthogonal (L s) (L t)) :
    Fintype.card K ≤ Fintype.card α - 1 := by
  obtain ⟨ x0, x1, hx0x1 ⟩ := Fintype.exists_pair_of_one_lt_card hα;
  -- For each `t : K`, the row map `row0 := (L t).toFun x0` is bijective. Let `e := Equiv.ofBijective _ (L t).row_bij x0`. Define `a t := e.symm ((L t).toFun x1 x0)`. Then `(L t).toFun x0 (a t) = (L t).toFun x1 x0`.
  have ha_def : ∀ t : K, ∃! a_val : α, (L t).toFun x0 a_val = (L t).toFun x1 x0 := by
    intro t
    obtain ⟨a_val, ha_val⟩ : ∃ a_val : α, (L t).toFun x0 a_val = (L t).toFun x1 x0 := by
      exact ( L t ).row_bij x0 |>.2 _
    use a_val
    constructor
    · exact ha_val
    · intro a_val' ha_val'
      have := (L t).row_bij x0
      exact this.injective ( ha_val'.trans ha_val.symm );
  choose a ha using fun t => ExistsUnique.exists ( ha_def t );
  -- Show that `a` is injective.
  have ha_inj : Function.Injective a := by
    intro s t hst
    by_contra h_neq;
    have := horth s t h_neq;
    have := this.injective; have := @this ( x1, x0 ) ( x0, a t ) ; simp_all +decide ;
    grind;
  -- Show that `a t ≠ x0` for all `t : K`.
  have ha_ne_x0 : ∀ t : K, a t ≠ x0 := by
    intro t ht; have := ha t; have := ( L t ).col_bij x0; simp_all +decide [ Function.Injective.eq_iff this.injective ] ;
  exact Nat.le_sub_one_of_lt ( by simpa using Set.card_lt_card ( show Set.range a ⊂ Set.univ from Set.ssubset_univ_iff.mpr <| Set.nonempty_compl.mp ⟨ x0, by aesop ⟩ ) |> fun h => by simpa [ Set.card_range_of_injective ha_inj ] using h )

end ItalianSquares