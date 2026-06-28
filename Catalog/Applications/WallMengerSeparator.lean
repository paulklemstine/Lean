import Mathlib

/-!
# Wall–Menger Separator Optimality

We study vertex separators in grid (wall) graphs and their optimality in the sense
of Menger duality. A `wall`/grid of size `(m+1) × (n+1)` is the Cartesian (box)
product `pathGraph (m+1) □ pathGraph (n+1)`. We separate the *left column*
`A = {x | x.2 = 0}` from the *right column* `B = {x | x.2 = last}`.

## Main results

* `WallMenger.IsABSeparator` — `S` meets every `A`–`B` walk.
* `WallMenger.menger_separator_lower_bound` — the easy (but genuinely useful)
  direction of Menger: `k` pairwise vertex-disjoint `A`–`B` paths force every
  `A`–`B` separator to have at least `k` vertices.
* `WallMenger.walk_exists_mem_support_of_le` — a discrete intermediate value
  theorem along a walk for any `ℕ`-valued vertex labelling whose value can grow by
  at most `1` across each edge.
* `WallMenger.grid_column_isSeparator` — every column of the grid is an `A`–`B`
  separator (via the discrete IVT on the column coordinate).
* `WallMenger.grid_rows_disjoint` — the `m+1` rows are pairwise vertex-disjoint
  `A`–`B` paths.
* `WallMenger.grid_disjoint_paths` — packaged statement that the grid admits
  `m+1` pairwise vertex-disjoint left-to-right paths (max-disjoint-paths side).
* `WallMenger.grid_separator_optimal` — **separator optimality**: there is an
  `A`–`B` separator of size `m+1` (a column) and every `A`–`B` separator has size
  at least `m+1`. Hence the minimum `A`–`B` separator of the `(m+1)×(n+1)` grid
  has exactly `m+1` vertices, matching the `m+1` disjoint horizontal paths.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): the "wall–Menger separator optimality" phenomenon is
  the tightness of the Menger inequality on grids: `min-cut = max disjoint paths`.
  For the left/right cut of an `(m+1)×(n+1)` grid both quantities should equal the
  height `m+1`.
* Experiment (Experimenter): proved the *lower bound* abstractly (disjoint paths ⇒
  large separator) by an injection from path-indices to separator vertices, then
  exhibited the matching column separator. The column-separator property is a
  discrete IVT on the column coordinate of a walk.
* Analysis (Analyst): full Menger (large separator ⇒ disjoint paths) is *not*
  needed here: the explicit row construction already supplies the disjoint paths,
  so the optimal value is pinned down without the hard direction.
* Critique (Critic): only the left/right cut is treated; general (`A`,`B`) Menger
  duality on grids and the converse direction remain open (see FUTURE_DIRECTIONS).
-- !-- end Lab Notes -- !--
-/

open SimpleGraph

namespace WallMenger

variable {V : Type*} {G : SimpleGraph V}

/-- `S` is an `A`–`B` separator: every walk from a vertex of `A` to a vertex of
`B` contains a vertex of `S`. -/
def IsABSeparator (G : SimpleGraph V) (A B S : Set V) : Prop :=
  ∀ ⦃u v⦄ (w : G.Walk u v), u ∈ A → v ∈ B → ∃ x ∈ w.support, x ∈ S

/--
**Menger lower bound (easy direction).** If there are `k` pairwise
vertex-disjoint `A`–`B` paths, then every `A`–`B` separator has at least `k`
vertices.
-/
theorem menger_separator_lower_bound
    {A B : Set V} {S : Finset V} (hS : IsABSeparator G A B (↑S))
    {k : ℕ} {a b : Fin k → V} (p : ∀ i, G.Walk (a i) (b i))
    (ha : ∀ i, a i ∈ A) (hb : ∀ i, b i ∈ B)
    (hdisj : ∀ i j, i ≠ j → ∀ x, x ∈ (p i).support → x ∉ (p j).support) :
    k ≤ S.card := by
  -- For each index i : Fin k, apply the separator hypothesis hS to the walk (p i) with (ha i) and (hb i). This yields a vertex x_i in (p i).support with x_i ∈ S.
  have h_exists_vertex : ∀ i : Fin k, ∃ x ∈ (p i).support, x ∈ S := by
    exact fun i => hS ( p i ) ( ha i ) ( hb i );
  choose f hf1 hf2 using h_exists_vertex;
  have h_card : Fintype.card (Fin k) ≤ Fintype.card {x // x ∈ S} := by
    exact Fintype.card_le_of_injective ( fun i => ⟨ f i, hf2 i ⟩ ) fun i j hij => Classical.not_not.1 fun hi => hdisj i j hi _ ( hf1 i ) ( by aesop );
  simpa using h_card

/--
**Discrete intermediate value theorem along a walk.** If `f` is a `ℕ`-valued
vertex labelling that increases by at most `1` across every edge, then a walk
from `u` to `v` with `f u ≤ c ≤ f v` contains a vertex `x` with `f x = c`.
-/
theorem walk_exists_mem_support_of_le {f : V → ℕ}
    (hstep : ∀ ⦃x y⦄, G.Adj x y → f y ≤ f x + 1)
    {u v : V} (w : G.Walk u v) {c : ℕ} (hu : f u ≤ c) (hv : c ≤ f v) :
    ∃ x ∈ w.support, f x = c := by
  induction' w with u v w ih;
  · exact ⟨ u, by simp +decide, by linarith ⟩;
  · grind +splitIndPred

/-! ## The grid / wall -/

/-- The `(m+1) × (n+1)` grid (wall) graph. -/
abbrev Grid (m n : ℕ) : SimpleGraph (Fin (m + 1) × Fin (n + 1)) :=
  pathGraph (m + 1) □ pathGraph (n + 1)

/-- Left column. -/
def leftCol (m n : ℕ) : Set (Fin (m + 1) × Fin (n + 1)) := {x | x.2 = 0}

/-- Right column. -/
def rightCol (m n : ℕ) : Set (Fin (m + 1) × Fin (n + 1)) := {x | x.2 = Fin.last n}

/-- The `c`-th column as a finset. -/
def colFinset (m n c : ℕ) : Finset (Fin (m + 1) × Fin (n + 1)) :=
  Finset.univ.filter (fun x => (x.2 : Fin (n + 1)).val = c)

/--
The column coordinate increases by at most `1` across each grid edge.
-/
theorem grid_col_step (m n : ℕ) {x y : Fin (m + 1) × Fin (n + 1)}
    (h : (Grid m n).Adj x y) : (y.2 : Fin (n + 1)).val ≤ (x.2 : Fin (n + 1)).val + 1 := by
  cases h <;> simp_all +decide [ pathGraph_adj ];
  omega

/--
Every column `c ≤ n` is an `A`–`B` separator (with `A` the left column and
`B` the right column).
-/
theorem grid_column_isSeparator (m n c : ℕ) (hc : c ≤ n) :
    IsABSeparator (Grid m n) (leftCol m n) (rightCol m n) (↑(colFinset m n c)) := by
  intro u v w hu hv;
  obtain ⟨x, hx⟩ : ∃ x ∈ w.support, (x.2 : Fin (n + 1)).val = c := by
    apply walk_exists_mem_support_of_le;
    · intro x y h; exact grid_col_step m n h;
    · unfold leftCol at hu; aesop;
    · exact hc.trans ( by rw [ show v.2 = Fin.last n from hv ] ; simp +decide );
  unfold colFinset; aesop;

/--
A column `c ≤ n` has exactly `m + 1` vertices (one per row).
-/
theorem grid_colFinset_card (m n c : ℕ) (hc : c ≤ n) : (colFinset m n c).card = m + 1 := by
  unfold colFinset;
  rw [ Finset.card_eq_of_bijective ];
  use fun i hi => ( ⟨ i, hi ⟩, ⟨ c, by linarith ⟩ );
  · grind +extAll;
  · aesop;
  · aesop

/-- The graph homomorphism `j ↦ (i, j)` embedding row `i` of the grid. -/
def rowHom (m n : ℕ) (i : Fin (m + 1)) : pathGraph (n + 1) →g Grid m n where
  toFun j := (i, j)
  map_rel' := by
    intro a b h
    exact boxProd_adj.mpr (Or.inr ⟨h, rfl⟩)

/-- The walk along row `i`, from `(i, 0)` to `(i, last)`. -/
noncomputable def rowWalk (m n : ℕ) (i : Fin (m + 1)) :
    (Grid m n).Walk (i, 0) (i, Fin.last n) :=
  ((pathGraph_preconnected (n + 1) 0 (Fin.last n)).some).map (rowHom m n i)

/--
Every vertex on `rowWalk i` lies in row `i`.
-/
theorem rowWalk_support_fst (m n : ℕ) (i : Fin (m + 1)) {x : Fin (m + 1) × Fin (n + 1)}
    (hx : x ∈ (rowWalk m n i).support) : x.1 = i := by
  contrapose! hx;
  intro h;
  obtain ⟨ j, hj ⟩ := List.mem_map.mp ( by simpa [ rowWalk ] using h );
  exact hx ( by simpa [ rowHom ] using congr_arg Prod.fst hj.2.symm )

/-- The `m + 1` rows are pairwise vertex-disjoint. -/
theorem grid_rows_disjoint (m n : ℕ) (i j : Fin (m + 1)) (hij : i ≠ j)
    (x : Fin (m + 1) × Fin (n + 1)) (hxi : x ∈ (rowWalk m n i).support) :
    x ∉ (rowWalk m n j).support := by
  intro hxj
  exact hij ((rowWalk_support_fst m n i hxi).symm.trans (rowWalk_support_fst m n j hxj))

/-- **The max-disjoint-paths side.** The `(m+1)×(n+1)` grid admits `m+1`
pairwise vertex-disjoint left-to-right paths (the rows). This pins the
*maximum number of disjoint paths* at `≥ m+1`, matching the `m+1` separator
below and witnessing Menger tightness for the left/right cut. -/
theorem grid_disjoint_paths (m n : ℕ) :
    ∃ (a b : Fin (m + 1) → Fin (m + 1) × Fin (n + 1))
      (p : ∀ i, (Grid m n).Walk (a i) (b i)),
      (∀ i, a i ∈ leftCol m n) ∧ (∀ i, b i ∈ rightCol m n) ∧
      (∀ i j, i ≠ j → ∀ x, x ∈ (p i).support → x ∉ (p j).support) :=
  ⟨_, _, rowWalk m n, fun _ => rfl, fun _ => rfl, grid_rows_disjoint m n⟩

/-- **Wall–Menger separator optimality.** For the left/right cut of the
`(m+1)×(n+1)` grid: there is an `A`–`B` separator with exactly `m+1` vertices,
and every `A`–`B` separator has at least `m+1` vertices. The minimum separator
therefore has exactly `m+1` vertices, matching the `m+1` disjoint horizontal
paths. -/
theorem grid_separator_optimal (m n : ℕ) (hn : 1 ≤ n) :
    (∃ S : Finset (Fin (m + 1) × Fin (n + 1)),
        IsABSeparator (Grid m n) (leftCol m n) (rightCol m n) (↑S) ∧ S.card = m + 1) ∧
    (∀ S : Finset (Fin (m + 1) × Fin (n + 1)),
        IsABSeparator (Grid m n) (leftCol m n) (rightCol m n) (↑S) → m + 1 ≤ S.card) := by
  refine ⟨⟨colFinset m n 1, grid_column_isSeparator m n 1 hn, grid_colFinset_card m n 1 hn⟩, ?_⟩
  intro S hS
  refine menger_separator_lower_bound hS (a := fun i => (i, 0))
    (b := fun i => (i, Fin.last n)) (rowWalk m n) (fun i => rfl) (fun i => rfl)
    (grid_rows_disjoint m n)

end WallMenger