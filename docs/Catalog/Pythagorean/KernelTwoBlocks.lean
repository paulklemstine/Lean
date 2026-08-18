import Pythagorean.KernelBlockCount

/-!
# The two-block column of the Stirling triangle

We compute in closed form the number of kernel patterns of length `n + 1` with exactly two
blocks:

`KernelPattern.stirling2_two : stirling2 (n + 1) 2 = 2 ^ n - 1`.

The proof is a bijection with the family of subsets of `Fin (n+1)` that contain `0` and are
not everything: such a subset is the block of `0`, and the pattern is recovered as the
canonical form of its indicator tuple.  The auxiliary lemma
`KernelPattern.card_image_canon` (the canonical form has exactly as many values as the tuple
it comes from) is of independent interest.
-/

open Finset

namespace KernelPattern

variable {n : ℕ} {α : Type*} [DecidableEq α]

/-- The canonical form of a tuple takes exactly as many values as the tuple itself. -/
theorem card_image_canon (f : Fin n → α) :
    (univ.image (canon f)).card = (univ.image f).card := by
  refine Finset.card_bij (fun x _ => f x) ?_ ?_ ?_
  · intro x _
    exact Finset.mem_image_of_mem f (Finset.mem_univ x)
  · intro x hx y hy hxy
    simp only [Finset.mem_image, Finset.mem_univ, true_and] at hx hy
    obtain ⟨a, rfl⟩ := hx
    obtain ⟨b, rfl⟩ := hy
    have := (eq_iff_canon_eq f _ _).1 hxy
    rwa [canon_canon_apply, canon_canon_apply] at this
  · intro y hy
    simp only [Finset.mem_image, Finset.mem_univ, true_and] at hy
    obtain ⟨a, rfl⟩ := hy
    exact ⟨canon f a, Finset.mem_image_of_mem _ (Finset.mem_univ a), apply_canon f a⟩

/-- The block of the index `0` in a pattern. -/
def blockSet (p : Fin (n + 1) → Fin (n + 1)) : Finset (Fin (n + 1)) :=
  univ.filter (fun i => p i = 0)

/-- The pattern attached to a subset: the canonical form of its indicator tuple. -/
def patternOfSet (s : Finset (Fin (n + 1))) : Fin (n + 1) → Fin (n + 1) :=
  canon (fun i => decide (i ∈ s))

theorem patternOfSet_mem_patterns (s : Finset (Fin (n + 1))) :
    patternOfSet s ∈ Patterns (n + 1) := canon_mem_patterns _

theorem apply_zero_of_mem_patterns {p : Fin (n + 1) → Fin (n + 1)} (hp : p ∈ Patterns (n + 1)) :
    p 0 = 0 := by
  have h := canon_le_self p 0
  rw [mem_patterns_iff.1 hp] at h
  simpa using Fin.le_zero_iff.1 h

theorem blockSet_patternOfSet {s : Finset (Fin (n + 1))} (h0 : 0 ∈ s) :
    blockSet (patternOfSet s) = s := by
  ext i
  simp only [blockSet, Finset.mem_filter, Finset.mem_univ, true_and, patternOfSet]
  constructor
  · intro hi
    by_contra hns
    have hval : decide ((canon (fun i => decide (i ∈ s)) i) ∈ s) = decide (i ∈ s) :=
      apply_canon (fun i => decide (i ∈ s)) i
    rw [hi] at hval
    simp [h0, hns] at hval
  · intro hi
    have hle : canon (fun i => decide (i ∈ s)) i ≤ 0 :=
      canon_le (by simp [h0, hi])
    simpa using Fin.le_zero_iff.1 hle

theorem nblocks_patternOfSet {s : Finset (Fin (n + 1))} (h0 : 0 ∈ s) (hne : s ≠ univ) :
    nblocks (patternOfSet s) = 2 := by
  obtain ⟨a, ha⟩ : ∃ a : Fin (n + 1), a ∉ s := by
    by_contra hcon
    push_neg at hcon
    exact hne (Finset.eq_univ_iff_forall.2 hcon)
  rw [nblocks, patternOfSet, card_image_canon]
  have himg : (univ.image (fun i => decide (i ∈ s))) = ({true, false} : Finset Bool) := by
    apply Finset.Subset.antisymm
    · intro b _
      cases b <;> simp
    · intro b hb
      simp only [Finset.mem_insert, Finset.mem_singleton] at hb
      rcases hb with rfl | rfl
      · exact Finset.mem_image.2 ⟨0, Finset.mem_univ _, by simp [h0]⟩
      · exact Finset.mem_image.2 ⟨a, Finset.mem_univ _, by simp [ha]⟩
  rw [himg]
  decide

theorem patternOfSet_blockSet {p : Fin (n + 1) → Fin (n + 1)} (hp : p ∈ Patterns (n + 1))
    (h2 : nblocks p = 2) : patternOfSet (blockSet p) = p := by
  have hp0 : p 0 = 0 := apply_zero_of_mem_patterns hp
  -- the image of `p` consists of `0` and one further value
  obtain ⟨u, v, huv, himg⟩ := Finset.card_eq_two.1 h2
  have h0mem : (0 : Fin (n + 1)) ∈ univ.image p := by
    rw [← hp0]
    exact Finset.mem_image_of_mem p (Finset.mem_univ 0)
  have hval : ∀ i j : Fin (n + 1), p i ≠ 0 → p j ≠ 0 → p i = p j := by
    intro i j hi hj
    have h0' : (0 : Fin (n + 1)) ∈ ({u, v} : Finset (Fin (n + 1))) := by rw [← himg]; exact h0mem
    have hi' : p i ∈ ({u, v} : Finset (Fin (n + 1))) := by
      rw [← himg]; exact Finset.mem_image_of_mem p (Finset.mem_univ i)
    have hj' : p j ∈ ({u, v} : Finset (Fin (n + 1))) := by
      rw [← himg]; exact Finset.mem_image_of_mem p (Finset.mem_univ j)
    simp only [Finset.mem_insert, Finset.mem_singleton] at h0' hi' hj'
    rcases h0' with h0' | h0' <;> rcases hi' with hi' | hi' <;> rcases hj' with hj' | hj' <;>
      simp_all
  have hmem : ∀ x : Fin (n + 1), (x ∈ blockSet p) ↔ p x = 0 := by
    intro x; simp [blockSet]
  have hker : Ker (fun i => decide (i ∈ blockSet p)) = Ker p := by
    funext i j
    refine propext ⟨fun h => ?_, fun h => ?_⟩
    · show p i = p j
      have h' : decide (i ∈ blockSet p) = decide (j ∈ blockSet p) := h
      rw [decide_eq_decide, hmem, hmem] at h'
      by_cases hi : p i = 0
      · rw [hi]
        exact (h'.1 hi).symm
      · exact hval i j hi (fun hj => hi (h'.2 hj))
    · show decide (i ∈ blockSet p) = decide (j ∈ blockSet p)
      have h' : p i = p j := h
      rw [decide_eq_decide, hmem, hmem, h']
  rw [patternOfSet, canon_congr hker, mem_patterns_iff.1 hp]

/-- The subsets that arise as blocks of `0` in a two-block pattern. -/
def twoBlockSets (n : ℕ) : Finset (Finset (Fin (n + 1))) :=
  univ.filter (fun s => 0 ∈ s ∧ s ≠ univ)

theorem card_twoBlockSets (n : ℕ) : (twoBlockSets n).card = 2 ^ n - 1 := by
  classical
  have hbij : (univ.filter (fun s : Finset (Fin (n + 1)) => 0 ∈ s)).card = 2 ^ n := by
    have h1 : (univ.filter (fun s : Finset (Fin (n + 1)) => 0 ∈ s)).card
        = ((univ.erase (0 : Fin (n + 1))).powerset).card := by
      refine Finset.card_nbij' (fun s => s.erase 0) (fun t => insert 0 t) ?_ ?_ ?_ ?_
      · intro s hs
        simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at hs
        simp only [Finset.mem_coe, Finset.mem_powerset]
        intro x hx
        simp only [Finset.mem_erase] at hx ⊢
        exact ⟨hx.1, Finset.mem_univ x⟩
      · intro t _
        simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and]
        exact Finset.mem_insert_self 0 t
      · intro s hs
        simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at hs
        exact Finset.insert_erase hs
      · intro t ht
        simp only [Finset.mem_coe, Finset.mem_powerset] at ht
        have h0 : (0 : Fin (n + 1)) ∉ t := fun h => (Finset.mem_erase.1 (ht h)).1 rfl
        exact Finset.erase_insert h0
    rw [h1, Finset.card_powerset, Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ,
      Fintype.card_fin]
    simp
  have huniv : (univ.filter (fun s : Finset (Fin (n + 1)) => 0 ∈ s))
      = insert (univ : Finset (Fin (n + 1))) (twoBlockSets n) := by
    ext s
    simp only [twoBlockSets, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_insert]
    constructor
    · intro hs
      by_cases hsu : s = univ
      · exact Or.inl hsu
      · exact Or.inr ⟨hs, hsu⟩
    · rintro (rfl | ⟨hs, -⟩)
      · exact Finset.mem_univ 0
      · exact hs
  have hnotmem : (univ : Finset (Fin (n + 1))) ∉ twoBlockSets n := by
    simp [twoBlockSets]
  rw [huniv, Finset.card_insert_of_notMem hnotmem] at hbij
  omega

/-- **Closed form for the two-block column.**  There are `2 ^ n - 1` kernel patterns of
length `n + 1` with exactly two blocks. -/
theorem stirling2_two (n : ℕ) : stirling2 (n + 1) 2 = 2 ^ n - 1 := by
  rw [stirling2, ← card_twoBlockSets n]
  refine Finset.card_nbij' blockSet patternOfSet ?_ ?_ ?_ ?_
  · intro p hp
    simp only [Finset.coe_filter, Set.mem_setOf_eq] at hp
    simp only [twoBlockSets, Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and]
    refine ⟨?_, ?_⟩
    · simp only [blockSet, Finset.mem_filter, Finset.mem_univ, true_and]
      exact apply_zero_of_mem_patterns hp.1
    · intro hcon
      have hall : ∀ i : Fin (n + 1), p i = 0 := by
        intro i
        have : i ∈ blockSet p := hcon ▸ Finset.mem_univ i
        simpa [blockSet] using this
      have h1 : nblocks p = 1 := by
        rw [nblocks]
        have : univ.image p = {0} := by
          ext x
          simp only [Finset.mem_image, Finset.mem_univ, true_and, Finset.mem_singleton]
          exact ⟨by rintro ⟨i, rfl⟩; exact hall i, fun h => ⟨0, by rw [hall 0, h]⟩⟩
        rw [this, Finset.card_singleton]
      rw [hp.2] at h1
      exact absurd h1 (by norm_num)
  · intro s hs
    simp only [twoBlockSets, Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ,
      true_and] at hs
    simp only [Finset.coe_filter, Set.mem_setOf_eq]
    exact ⟨patternOfSet_mem_patterns s, nblocks_patternOfSet hs.1 hs.2⟩
  · intro p hp
    simp only [Finset.coe_filter, Set.mem_setOf_eq] at hp
    exact patternOfSet_blockSet hp.1 hp.2
  · intro s hs
    simp only [twoBlockSets, Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ,
      true_and] at hs
    exact blockSet_patternOfSet hs.1

/-- Consistency check against the `decide`-verified table: `stirling2 5 2 = 15 = 2^4 - 1`. -/
theorem stirling2_two_five : stirling2 5 2 = 15 := by
  have := stirling2_two 4
  norm_num at this
  exact this

/-- Consequence for the Bell numbers: an exponential lower bound.  Summing the Stirling row
over just the one- and two-block columns already gives `2 ^ n`. -/
theorem two_pow_le_bell_succ (n : ℕ) : 2 ^ n ≤ Nat.bell (n + 1) := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  · have hsub : ({1, 2} : Finset ℕ) ⊆ Finset.range (n + 2) := by
      intro k hk
      simp only [Finset.mem_insert, Finset.mem_singleton] at hk
      rcases hk with rfl | rfl <;> simp only [Finset.mem_range] <;> omega
    have hle : ∑ k ∈ ({1, 2} : Finset ℕ), stirling2 (n + 1) k
        ≤ ∑ k ∈ Finset.range (n + 2), stirling2 (n + 1) k :=
      Finset.sum_le_sum_of_subset hsub
    rw [sum_stirling2_eq_bell] at hle
    have hval : ∑ k ∈ ({1, 2} : Finset ℕ), stirling2 (n + 1) k = 2 ^ n := by
      rw [Finset.sum_insert (by simp), Finset.sum_singleton, stirling2_one, stirling2_two]
      have : 1 ≤ 2 ^ n := Nat.one_le_two_pow
      omega
    omega

end KernelPattern