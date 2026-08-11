import Mathlib
import Novelty.WallMengerCore

/-!
# The linear-in-`r` subwall pigeonhole and the one-set wall–Menger dichotomy

This file supplies the second ingredient of the conjectured one-set wall–Menger
bound: the **explicit linear height** `T(s,r) = (8s+4)r` that guarantees a clean
`r`-subwall, and the assembly of the dichotomy together with the packing–cover
duality of `WallMengerCore.lean`.

## Why `T(s,r) = (8s+4)r`

An elementary wall of height `(8s+4)r` contains `8s+4` *vertex-disjoint*
`r`-subwalls (stack them `r` rows at a time).  This is the tiling
`Ico (i·r) ((i+1)·r)`, `i < 8s+4`, of the height interval `range ((8s+4)·r)`
(`subwall_tiling`).  Because the separator side of the dichotomy costs at most
`F(s) = 4s-4 < 8s+4` vertices, and the subwalls are pairwise disjoint, a separator
can meet at most `4s-4` of the `8s+4` subwalls; some `r`-subwall therefore survives
(`exists_clean_subwall`).

## Main results

* `subwall_tiling` — height `T(s,r)` tiles into `8s+4` disjoint `r`-blocks.
* `exists_clean_subwall` — a size-`≤ 4s-4` separator misses some `r`-subwall.
* `wall_menger_dichotomy` — **the one-set dichotomy**: either `s` pairwise-disjoint
  `A`–wall path traces exist, or a separator of size `≤ F(s)` hits them all *and*
  leaves an entire `r`-subwall untouched.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): the wall height in the conjecture is linear in `r`
  because finding an `r`-subwall is pigeonhole over `Θ(s)` disjoint `r`-blocks,
  not a tree-width / grid-minor blow-up.  Predicted threshold: `(8s+4)r`.
* Experiment (Experimenter): proved the tiling (`Nat.Ico` disjointness + a
  `range` reassembly) and the pigeonhole `#{i : W i meets X} ≤ |X|` via an
  injection `i ↦ (a chosen element of W i ∩ X)`, injective because the subwalls
  are pairwise disjoint.  Then `|X| ≤ 4s-4 < 8s+4 = #blocks` forces a clean block.
* Analysis (Analyst): the injection step is where *pairwise disjointness* of the
  subwalls is consumed; without it a single separator vertex could spoil many
  subwalls and the count would fail.  `8s+4 > 4s-4` (strict, for all `s ≥ 0`) is
  the precise slack making the pigeonhole go through with room to spare — the
  conjecture could even afford `(6s)r`, recorded as a future direction.
* Critique (Critic): `wall_menger_dichotomy` is *honest* — it does NOT claim the
  `s` paths land on distinct nails of one subwall (that needs the full wall
  routing geometry, beyond this abstraction).  It proves exactly the part that the
  greedy duality + pigeonhole deliver: a packing of `s` paths, or a small
  separator that additionally spares a whole `r`-subwall.
* Synthesis (PI): the two explicit constants of the paper, `T(s,r)=(8s+4)r` and
  `F(s)=4s-4`, are reproduced from first principles by these two lemmas.
-- !-- end Lab Notes -- !--
-/

open Finset

namespace WallMenger

/-- `T(s,r) = (8s+4)·r`, the conjectured (linear in `r`) wall height. -/
def T (s r : ℕ) : ℕ := (8 * s + 4) * r

/-- `F(s) = 4s - 4`, the conjectured separator bound. -/
def F (s : ℕ) : ℕ := 4 * s - 4

/-- The `i`-th height block of an `r`-subwall tiling: rows `[i·r, (i+1)·r)`. -/
def subwallBlock (r i : ℕ) : Finset ℕ := Finset.Ico (i * r) ((i + 1) * r)

/-- **Subwall tiling.**  The `8s+4` blocks of height `r` are pairwise disjoint,
each has exactly `r` rows, and together they tile the full height interval
`range (T s r)`.  Thus a wall of height `T s r` hosts `8s+4` disjoint `r`-subwalls. -/
theorem subwall_tiling (s r : ℕ) :
    (Set.Pairwise (↑(Finset.range (8 * s + 4))) (fun i j => Disjoint (subwallBlock r i) (subwallBlock r j)))
    ∧ (∀ i, (subwallBlock r i).card = r)
    ∧ (Finset.range (8 * s + 4)).biUnion (subwallBlock r) = Finset.range (T s r) := by
  refine ⟨?_, ?_, ?_⟩
  · -- pairwise disjoint
    intro i _ j _ hij
    apply Finset.disjoint_left.2
    intro a hai haj
    simp only [subwallBlock, Finset.mem_Ico] at hai haj
    rcases Nat.lt_or_ge i j with h | h
    · have : (i + 1) * r ≤ j * r := Nat.mul_le_mul_right r h
      omega
    · have hji : j < i := lt_of_le_of_ne h (Ne.symm hij)
      have : (j + 1) * r ≤ i * r := Nat.mul_le_mul_right r hji
      omega
  · -- each block has card r
    intro i
    simp only [subwallBlock, Nat.card_Ico]
    ring_nf
    omega
  · -- the blocks tile range (T s r)
    ext a
    simp only [Finset.mem_biUnion, Finset.mem_range, subwallBlock, Finset.mem_Ico, T]
    constructor
    · rintro ⟨i, hi, hai1, hai2⟩
      calc a < (i + 1) * r := hai2
        _ ≤ (8 * s + 4) * r := Nat.mul_le_mul_right r (by omega)
    · intro ha
      rcases Nat.eq_zero_or_pos r with hr | hr
      · subst hr; simp at ha
      refine ⟨a / r, ?_, ?_, ?_⟩
      · rw [Nat.div_lt_iff_lt_mul hr]; omega
      · have := Nat.div_mul_le_self a r
        omega
      · have h1 := Nat.div_add_mod a r
        have h2 := Nat.mod_lt a hr
        nlinarith [h1, h2]

/-- **Clean subwall.**  In a wall of height `T s r` decomposed into `8s+4`
pairwise-disjoint `r`-subwalls, any separator `X` of size at most `F s = 4s-4`
misses some `r`-subwall entirely.  The slack `8s+4 > 4s-4` is exactly what the
pigeonhole consumes. -/
theorem exists_clean_subwall {V : Type*} [DecidableEq V] (s : ℕ)
    (W : Fin (8 * s + 4) → Finset V)
    (hWdisj : ∀ i j, i ≠ j → Disjoint (W i) (W j))
    (X : Finset V) (hX : X.card ≤ F s) :
    ∃ i, Disjoint (W i) X := by
  classical
  by_contra h
  push_neg at h
  -- every subwall meets `X`; choose a witness in each
  have hwit : ∀ i, ∃ a, a ∈ W i ∧ a ∈ X := fun i => Finset.not_disjoint_iff.1 (h i)
  choose f hfW hfX using hwit
  -- `f` is injective into `X` because the subwalls are pairwise disjoint
  have hinj : Set.InjOn f (↑(Finset.univ : Finset (Fin (8 * s + 4)))) := by
    intro i _ j _ hfij
    by_contra hij
    have : Disjoint (W i) (W j) := hWdisj i j hij
    rw [Finset.disjoint_left] at this
    exact this (hfW i) (hfij ▸ hfW j)
  have hmaps : ∀ i ∈ (Finset.univ : Finset (Fin (8 * s + 4))), f i ∈ X := fun i _ => hfX i
  have hcard : (Finset.univ : Finset (Fin (8 * s + 4))).card ≤ X.card :=
    Finset.card_le_card_of_injOn f hmaps hinj
  rw [Finset.card_univ, Fintype.card_fin] at hcard
  simp only [F] at hX
  omega

/-- **One-set wall–Menger dichotomy (abstract form).**  Given an elementary wall
presented as `8s+4` pairwise-disjoint `r`-subwalls `W` and a family `Fam` of
`A`–nail path traces (each nonempty, each of size at most `4`), one of the two
horns holds:

* (**packing**) there are `s` pairwise vertex-disjoint `A`–wall path traces, or
* (**separation**) there is a separator `X` with `|X| ≤ F s = 4s-4` that hits every
  path trace *and* leaves an entire `r`-subwall `W i` untouched.

This combines the greedy packing–cover duality (`wall_menger_separator_bound`)
with the clean-subwall pigeonhole (`exists_clean_subwall`). -/
theorem wall_menger_dichotomy {V : Type*} [DecidableEq V] (s : ℕ) (hs : 1 ≤ s)
    (W : Fin (8 * s + 4) → Finset V)
    (hWdisj : ∀ i j, i ≠ j → Disjoint (W i) (W j))
    (Fam : Finset (Finset V))
    (hne : ∀ A ∈ Fam, A.Nonempty) (hc : ∀ A ∈ Fam, A.card ≤ 4) :
    (∃ P : Finset (Finset V), P ⊆ Fam ∧
        (↑P : Set (Finset V)).PairwiseDisjoint id ∧ s ≤ P.card)
      ∨ (∃ X : Finset V, X.card ≤ F s ∧ (∀ A ∈ Fam, ¬ Disjoint A X) ∧
          ∃ i, Disjoint (W i) X) := by
  by_cases hpack : ∃ P : Finset (Finset V), P ⊆ Fam ∧
      (↑P : Set (Finset V)).PairwiseDisjoint id ∧ s ≤ P.card
  · exact Or.inl hpack
  · right
    obtain ⟨X, hXcard, hXhit⟩ := wall_menger_separator_bound Fam s hs hne hc hpack
    have hXF : X.card ≤ F s := by simp only [F]; exact hXcard
    obtain ⟨i, hi⟩ := exists_clean_subwall s W hWdisj X hXF
    exact ⟨X, hXF, hXhit, i, hi⟩

end WallMenger