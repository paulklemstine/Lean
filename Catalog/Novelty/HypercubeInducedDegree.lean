/-
# Induced subgraphs of bounded degree in the hypercube

This file generalises the counting core of `Computation.SnakeInTheBox` from
snakes to *arbitrary* vertex sets.  The double count used there —
"a chordless path sends many edges out of itself, and the complement can only
absorb so many" — never uses the path structure: it only uses the bound
`deg_S(x) ≤ 2` on the number of neighbours of a snake vertex inside the snake.

The main theorem here is therefore

> **Density theorem.**  If `S ⊆ Q n` induces a subgraph of maximum degree at
> most `d`, then `(2n - d) · |S| ≤ n · 2 ^ n`.

For `d = 2` (induced disjoint unions of paths and cycles, i.e. *all* snakes,
all coils, and all their disjoint unions at once) this gives
`|S| ≤ 3 · 2 ^ (n - 2)` for `n ≥ 3`, and the bound is **attained** in `Q 3` by
the induced hexagon.  For `d = 0` it is the (correct) statement that an
independent set... no: it gives `|S| ≤ 2 ^ (n-1)`, the exact size of a parity
class, so the theorem is sharp at both ends of the range `d = 0` and `d = 2`
in dimension three.

The snake bound `Snake.card_le` of the catalog is recovered as a one-line
corollary, which is the precise sense in which this file extends the catalog.
-/
import Mathlib
import Computation.SnakeInTheBox

namespace SnakeInTheBox

open Finset

variable {n : ℕ}

/-! ## Degrees relative to a vertex set -/

/-- The number of neighbours of `x` inside `S`. -/
def indeg (S : Finset (Cube n)) (x : Cube n) : ℕ := (S.filter fun y => Adj x y).card

/-- The number of neighbours of `x` outside `S`. -/
def outdeg (S : Finset (Cube n)) (x : Cube n) : ℕ := (Sᶜ.filter fun y => Adj x y).card

/-- Inside and outside degrees add up to the degree `n` of the hypercube. -/
theorem indeg_add_outdeg (S : Finset (Cube n)) (x : Cube n) :
    indeg S x + outdeg S x = n := by
  have hdisj : Disjoint (S.filter fun y => Adj x y) (Sᶜ.filter fun y => Adj x y) := by
    rw [Finset.disjoint_left]
    intro a ha hb
    simp only [Finset.mem_filter, Finset.mem_compl] at ha hb
    exact hb.1 ha.1
  have hunion : (S.filter fun y => Adj x y) ∪ (Sᶜ.filter fun y => Adj x y)
      = univ.filter fun y => Adj x y := by
    ext y
    simp only [Finset.mem_union, Finset.mem_filter, Finset.mem_compl, Finset.mem_univ, true_and]
    by_cases hy : y ∈ S <;> simp [hy]
  unfold indeg outdeg
  rw [← Finset.card_union_of_disjoint hdisj, hunion, card_sphere x]

/-- The edge boundary of `S`: the number of hypercube edges with exactly one end in `S`. -/
def edgeBoundary (S : Finset (Cube n)) : ℕ := ∑ x ∈ S, outdeg S x

/-- Each vertex outside `S` absorbs at most `n` boundary edges. -/
theorem edgeBoundary_le (S : Finset (Cube n)) : edgeBoundary S ≤ n * (2 ^ n - S.card) := by
  have hcompl : Sᶜ.card = 2 ^ n - S.card := by
    rw [card_compl]
    simp [Finset.card_univ]
  have hswap : edgeBoundary S = ∑ y ∈ Sᶜ, (S.filter fun x => Adj x y).card := by
    unfold edgeBoundary outdeg
    simp_rw [Finset.card_filter]
    rw [Finset.sum_comm]
  have hle : ∀ y ∈ Sᶜ, (S.filter fun x => Adj x y).card ≤ n := by
    intro y _
    have huniv : (univ.filter fun x => Adj x y).card = n := by
      have heq : (univ.filter fun x => Adj x y) = (univ.filter fun x => Adj y x) := by
        ext x
        simp only [Finset.mem_filter, Finset.mem_univ, true_and]
        exact ⟨adj_symm, adj_symm⟩
      rw [heq, card_sphere]
    calc (S.filter fun x => Adj x y).card
        ≤ (univ.filter fun x => Adj x y).card :=
          Finset.card_le_card (Finset.filter_subset_filter _ (Finset.subset_univ S))
      _ = n := huniv
  calc edgeBoundary S = ∑ y ∈ Sᶜ, (S.filter fun x => Adj x y).card := hswap
    _ ≤ ∑ _ ∈ Sᶜ, n := Finset.sum_le_sum hle
    _ = n * Sᶜ.card := by simp [mul_comm]
    _ = n * (2 ^ n - S.card) := by rw [hcompl]

/-- A set of maximum induced degree `d` sends at least `(n - d) · |S|` edges out of itself. -/
theorem edgeBoundary_ge {S : Finset (Cube n)} {d : ℕ} (h : ∀ x ∈ S, indeg S x ≤ d) :
    (n - d) * S.card ≤ edgeBoundary S := by
  have hpt : ∀ x ∈ S, n - d ≤ outdeg S x := by
    intro x hx
    have := indeg_add_outdeg S x
    have := h x hx
    omega
  calc (n - d) * S.card = ∑ _ ∈ S, (n - d) := by simp [mul_comm]
    _ ≤ ∑ x ∈ S, outdeg S x := Finset.sum_le_sum hpt
    _ = edgeBoundary S := rfl

/-- **Density theorem for induced subgraphs of the hypercube.**  If every vertex of `S`
has at most `d` neighbours inside `S`, then `(n - d) |S| + n |S| ≤ n 2 ^ n`. -/
theorem card_mul_le_of_indeg_le {S : Finset (Cube n)} {d : ℕ} (h : ∀ x ∈ S, indeg S x ≤ d) :
    (n - d) * S.card + n * S.card ≤ n * 2 ^ n := by
  have h1 := edgeBoundary_ge h
  have h2 := edgeBoundary_le S
  have h3 : S.card ≤ 2 ^ n := by
    have := Finset.card_le_univ S
    simpa [Finset.card_univ] using this
  have h4 : n * (2 ^ n - S.card) + n * S.card = n * 2 ^ n := by
    rw [Nat.mul_sub, Nat.sub_add_cancel (Nat.mul_le_mul_left n h3)]
  omega

/-- The same statement in the form `(2n - d)|S| ≤ n 2ⁿ`, valid when `d ≤ n`. -/
theorem card_mul_le_of_indeg_le' {S : Finset (Cube n)} {d : ℕ} (hd : d ≤ n)
    (h : ∀ x ∈ S, indeg S x ≤ d) : (2 * n - d) * S.card ≤ n * 2 ^ n := by
  have hkey := card_mul_le_of_indeg_le h
  have : (2 * n - d) = (n - d) + n := by omega
  rw [this, add_mul]
  exact hkey

/-- **Maximum degree two.**  A set of vertices of `Q n` (`n ≥ 3`) inducing a disjoint union
of paths and cycles has at most `3 · 2 ^ (n - 2)` vertices. -/
theorem card_le_of_indeg_le_two {S : Finset (Cube n)} (hn : 3 ≤ n)
    (h : ∀ x ∈ S, indeg S x ≤ 2) : S.card ≤ 3 * 2 ^ (n - 2) := by
  have h1 : (2 * n - 2) * S.card ≤ n * 2 ^ n := card_mul_le_of_indeg_le' (by omega) h
  have hpow : 2 ^ n = 2 ^ (n - 2) * 4 := by
    have : n = (n - 2) + 2 := (Nat.sub_add_cancel (by omega)).symm
    conv_lhs => rw [this, pow_add]
    norm_num
  have h2 : n * 2 ^ n ≤ 3 * 2 ^ (n - 2) * (2 * n - 2) := by
    have hkey : 4 * n ≤ 3 * (2 * n - 2) := by omega
    calc n * 2 ^ n = 4 * n * 2 ^ (n - 2) := by rw [hpow]; ring
      _ ≤ 3 * (2 * n - 2) * 2 ^ (n - 2) := by gcongr
      _ = 3 * 2 ^ (n - 2) * (2 * n - 2) := by ring
  have h3 : S.card * (2 * n - 2) ≤ 3 * 2 ^ (n - 2) * (2 * n - 2) := by
    rw [mul_comm] at h1
    exact le_trans h1 h2
  exact Nat.le_of_mul_le_mul_right h3 (by omega)

/-- **Independent sets.**  A set with no internal edge has at most `2 ^ (n-1)` vertices —
the exact size of a parity class, so the density theorem is sharp at `d = 0`. -/
theorem card_le_of_indeg_le_zero {S : Finset (Cube n)} (hn : 1 ≤ n)
    (h : ∀ x ∈ S, indeg S x = 0) : S.card ≤ 2 ^ (n - 1) := by
  have h' : ∀ x ∈ S, indeg S x ≤ 0 := fun x hx => (h x hx).le
  have h1 : (2 * n - 0) * S.card ≤ n * 2 ^ n := card_mul_le_of_indeg_le' (Nat.zero_le _) h'
  have hpow : 2 ^ n = 2 ^ (n - 1) * 2 := by
    have : n = (n - 1) + 1 := (Nat.sub_add_cancel hn).symm
    conv_lhs => rw [this, pow_add]
    norm_num
  have h2 : S.card * (2 * n) ≤ 2 ^ (n - 1) * (2 * n) := by
    calc S.card * (2 * n) = (2 * n - 0) * S.card := by rw [Nat.sub_zero]; ring
      _ ≤ n * 2 ^ n := h1
      _ = 2 ^ (n - 1) * (2 * n) := by rw [hpow]; ring
  exact Nat.le_of_mul_le_mul_right h2 (by omega)

/-! ## Application: the snake bound, and sharpness -/

variable {L : ℕ}

/-- The vertex set of a snake has maximum induced degree two. -/
theorem Snake.indeg_le_two (s : Snake n L) : ∀ x ∈ s.vset, indeg s.vset x ≤ 2 :=
  fun _ hx => s.degree_le_two hx

/-- The catalog bound `Snake.card_le` is a corollary of the density theorem. -/
theorem Snake.card_le_of_density (s : Snake n L) (hn : 3 ≤ n) : L + 1 ≤ 3 * 2 ^ (n - 2) := by
  have := card_le_of_indeg_le_two hn s.indeg_le_two
  rwa [s.card_vset] at this

end SnakeInTheBox