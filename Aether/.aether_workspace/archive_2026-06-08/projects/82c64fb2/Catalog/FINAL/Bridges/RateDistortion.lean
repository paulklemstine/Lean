/-
# Rate-Distortion Theory for Finite Metric Spaces

This file formalizes the core packing-covering theory for finite metric spaces,
establishing the foundational inequalities that connect metric covering numbers
and packing numbers. These results form the combinatorial backbone of
rate-distortion theory, with applications to lossy compression, learning theory,
and geometric approximation.

## Main definitions

- `isSeparated C r`: Every pair of distinct points in `C` has distance ≥ `r`.
- `isCovering C R`: Every point of the ambient space is within distance `R`
  of some point in `C`.

## Main results

- `maximal_separated_implies_covering`: A maximal `r`-separated set is an `r`-covering.
- `card_le_of_separated_and_covering`: If `S` is `s`-separated, `C` is `r`-covering,
  and `2r < s`, then `|S| ≤ |C|`.
- `exists_separated_and_covering`: There exists a set that is both `r`-separated
  and `r`-covering.
- `card_le_of_separated_subset_interval`: Packing bound for bounded intervals.
-/

import Mathlib

open Finset

variable {α : Type*}

/-! ### Core Definitions -/

/-- A finite set `C` is `r`-separated if every pair of distinct points has distance
at least `r`. -/
def isSeparated [PseudoMetricSpace α] (C : Finset α) (r : ℝ) : Prop :=
  ∀ ⦃x⦄, x ∈ C → ∀ ⦃y⦄, y ∈ C → x ≠ y → r ≤ dist x y

/-- A finite set `C` is an `R`-covering if every point of the space is within
distance `R` of some point of `C`. -/
def isCovering [PseudoMetricSpace α] [Fintype α] (C : Finset α) (R : ℝ) : Prop :=
  ∀ x : α, ∃ y ∈ C, dist x y ≤ R

/-! ### Basic lemmas about isSeparated -/

/-- The empty set is `r`-separated for any `r`. -/
theorem isSeparated_empty [PseudoMetricSpace α] (r : ℝ) :
    isSeparated (∅ : Finset α) r := by
  intro x hx; simp at hx

/-- A singleton set is `r`-separated for any `r`. -/
theorem isSeparated_singleton [PseudoMetricSpace α] [DecidableEq α] (a : α) (r : ℝ) :
    isSeparated ({a} : Finset α) r := by
  intro x hx y hy hne
  simp at hx hy
  exact absurd (hx ▸ hy.symm) hne

/-- If `C` is `r`-separated and `r' ≤ r`, then `C` is `r'`-separated. -/
theorem isSeparated.mono [PseudoMetricSpace α] {C : Finset α} {r r' : ℝ}
    (h : isSeparated C r) (hr : r' ≤ r) : isSeparated C r' :=
  fun _ hx _ hy hne => le_trans hr (h hx hy hne)

/-- A subset of a separated set is separated. -/
theorem isSeparated.subset [PseudoMetricSpace α] {C D : Finset α} {r : ℝ}
    (h : isSeparated C r) (hCD : D ⊆ C) : isSeparated D r :=
  fun _ hx _ hy hne => h (hCD hx) (hCD hy) hne

/-! ### Basic lemmas about isCovering -/

/-- If `C` is `R`-covering and `R ≤ R'`, then `C` is `R'`-covering. -/
theorem isCovering.mono [PseudoMetricSpace α] [Fintype α] {C : Finset α} {R R' : ℝ}
    (h : isCovering C R) (hR : R ≤ R') : isCovering C R' :=
  fun x => let ⟨y, hy, hd⟩ := h x; ⟨y, hy, le_trans hd hR⟩

/-- `Finset.univ` is a `0`-covering of any finite type. -/
theorem isCovering_univ [PseudoMetricSpace α] [Fintype α] :
    isCovering (Finset.univ : Finset α) 0 :=
  fun x => ⟨x, mem_univ x, by simp⟩

/-- A covering set is nonempty if the space is nonempty. -/
theorem isCovering.nonempty [PseudoMetricSpace α] [Fintype α] [Nonempty α]
    {C : Finset α} {R : ℝ} (h : isCovering C R) : C.Nonempty := by
  obtain ⟨x⟩ := ‹Nonempty α›
  obtain ⟨y, hy, _⟩ := h x
  exact ⟨y, hy⟩

/-! ### Main Theorems -/

/-
**Maximal separated implies covering.**
If `C` is a maximal `r`-separated set with `0 ≤ r`, then `C` is an `r`-covering.

For any `x ∉ C`, maximality gives some `y ∈ C` with `dist x y < r ≤ r`.
For `x ∈ C`, we use `dist x x = 0 ≤ r`.
-/
theorem maximal_separated_implies_covering
    [PseudoMetricSpace α] [Fintype α] [DecidableEq α]
    {C : Finset α} {r : ℝ} (hr : 0 ≤ r)
    (hsep : isSeparated C r)
    (hmax : ∀ x : α, x ∉ C → ¬ isSeparated (insert x C) r) :
    isCovering C r := by
  -- For any $x \notin C$, there exists $y \in C$ such that $dist x y < r$ by the maximality condition.
  have hx : ∀ x ∉ C, ∃ y ∈ C, dist x y < r := by
    intro x hx
    by_contra h_no_y;
    refine' hmax x hx ( fun y hy z hz hyz => _ );
    cases' Finset.mem_insert.mp hy with hy hy <;> cases' Finset.mem_insert.mp hz with hz hz <;> simp_all +decide [ dist_comm ];
    exact hsep hy hz hyz;
  exact fun x => if hx' : x ∈ C then ⟨ x, hx', by simp +decide [ dist_self, hr ] ⟩ else by obtain ⟨ y, hy, hy' ⟩ := hx x hx'; exact ⟨ y, hy, hy'.le ⟩ ;

/-
**Packing-covering cardinality bound.**
If `S` is `s`-separated and `C` is `r`-covering with `2r < s`, then `|S| ≤ |C|`.

The map sending each `s ∈ S` to a nearest center in `C` is injective: if two distinct
points `s₁, s₂ ∈ S` map to the same `c ∈ C`, then
`s ≤ dist s₁ s₂ ≤ dist s₁ c + dist c s₂ ≤ 2r < s`, contradiction.
-/
theorem card_le_of_separated_and_covering
    [PseudoMetricSpace α] [Fintype α] [DecidableEq α]
    {S C : Finset α} {s r : ℝ}
    (hrs : 2 * r < s)
    (hS : isSeparated S s)
    (hC : isCovering C r) :
    S.card ≤ C.card := by
  -- Define a function that maps each point in `S` to a nearest center in `C`.
  obtain ⟨f, hf⟩ : ∃ f : α → α, (∀ x ∈ S, f x ∈ C ∧ dist x (f x) ≤ r) := by
    exact ⟨ fun x => if hx : x ∈ S then Classical.choose ( hC x ) else x, fun x hx => by simpa [ hx ] using Classical.choose_spec ( hC x ) ⟩;
  have h_inj : ∀ x ∈ S, ∀ y ∈ S, x ≠ y → f x ≠ f y := by
    intro x hx y hy hxy hfy
    have h_dist : dist x y ≤ dist x (f x) + dist (f x) y := by
      exact dist_triangle _ _ _;
    linarith [ hS hx hy hxy, hf x hx, hf y hy, dist_comm ( f x ) y, dist_comm ( f y ) x, hfy ▸ hf x hx, hfy ▸ hf y hy ];
  exact Finset.card_le_card ( show S.image f ⊆ C from Finset.image_subset_iff.mpr fun x hx => ( hf x hx ).1 ) |> le_trans ( by rw [ Finset.card_image_of_injOn fun x hx y hy hxy => by contrapose! hxy; exact h_inj x hx y hy hxy ] )

/-
**Existence of a set that is both separated and covering.**
For any finite metric space and `r ≥ 0`, there exists a set that is both
`r`-separated and `r`-covering.
-/
theorem exists_separated_and_covering
    [PseudoMetricSpace α] [Fintype α] [DecidableEq α]
    {r : ℝ} (hr : 0 ≤ r) :
    ∃ C : Finset α, isSeparated C r ∧ isCovering C r := by
  -- Let C be a maximal r-separated subset of α.
  obtain ⟨C, hC_max⟩ : ∃ C : Finset α, isSeparated C r ∧ ∀ D : Finset α, isSeparated D r → C.card ≥ D.card := by
    apply_rules [ Set.exists_max_image ];
    · exact Set.toFinite _;
    · exact ⟨ ∅, isSeparated_empty r ⟩;
  refine' ⟨ C, hC_max.1, maximal_separated_implies_covering hr hC_max.1 fun x hx hsep => _ ⟩;
  exact not_lt_of_ge ( hC_max.2 _ hsep ) ( Finset.card_lt_card ( Finset.ssubset_insert hx ) )

/-! ### Quantitative Bounds: 1-dimensional rational case -/

/-
**Packing bound on bounded intervals (rationals).**
If `S` is a finite set of rationals with `|x| ≤ B` for all `x ∈ S`, and every pair of
distinct elements has distance at least `r > 0`, then `|S| ≤ ⌊2B/r⌋ + 1`.

This is the 1-dimensional box-packing bound, giving a concrete rate upper bound
for bounded sources.
-/
theorem card_le_of_separated_subset_interval
    {S : Finset ℚ} {B r : ℚ}
    (hr : 0 < r)
    (hsep : ∀ ⦃x⦄, x ∈ S → ∀ ⦃y⦄, y ∈ S → x ≠ y → r ≤ |x - y|)
    (hbounded : ∀ x ∈ S, |x| ≤ B) :
    S.card ≤ Nat.floor (2 * B / r) + 1 := by
  -- Define the function $f(x) = \lfloor (x + B) / r \rfloor$.
  set f : ℚ → ℕ := fun x => Nat.floor ((x + B) / r) with hf_def;
  -- The map $f$ is injective on $S$: if $x \neq y$ in $S$ with $f(x) = f(y) = k$, then both $(x + B)/r$ and $(y + B)/r$ are in $[k, k+1)$, so $|(x + B)/r - (y + B)/r| < 1$, meaning $|x - y|/r < 1$, so $|x - y| < r$. But $hsep$ gives $r \leq |x - y|$, contradiction.
  have h_inj : ∀ x ∈ S, ∀ y ∈ S, x ≠ y → f x ≠ f y := by
    intro x hx y hy hxy; specialize hsep hx hy hxy; contrapose! hsep; simp_all +decide ;
    rw [ Nat.floor_eq_iff ] at hsep;
    · cases abs_cases ( x - y ) <;> nlinarith [ Nat.floor_le ( show 0 ≤ ( y + B ) / r by exact div_nonneg ( by linarith [ abs_le.mp ( hbounded y hy ) ] ) hr.le ), Nat.lt_floor_add_one ( ( y + B ) / r ), mul_div_cancel₀ ( x + B ) hr.ne', mul_div_cancel₀ ( y + B ) hr.ne' ];
    · exact div_nonneg ( by linarith [ abs_le.mp ( hbounded x hx ) ] ) hr.le;
  -- Since $f$ maps $S$ injectively into $\{0, 1, ..., \lfloor 2B/r \rfloor\}$, we get $S.card \leq \lfloor 2B/r \rfloor + 1$.
  have h_card : S.card ≤ Finset.card (Finset.image f S) := by
    rw [ Finset.card_image_of_injOn fun x hx y hy hxy => by contrapose! hxy; exact h_inj x hx y hy hxy ];
  refine le_trans h_card ?_;
  exact le_trans ( Finset.card_le_card ( Finset.image_subset_iff.mpr fun x hx => Finset.mem_Icc.mpr ⟨ Nat.zero_le _, show f x ≤ ⌊2 * B / r⌋₊ from Nat.floor_mono <| by rw [ div_le_div_iff_of_pos_right hr ] ; linarith [ abs_le.mp ( hbounded x hx ) ] ⟩ ) ) ( by simp +arith +decide )