import Tropical.DependentFibers.Core

/-!
# Corners exist, corners are rare

Two complementary facts about the fibre family `x ↦ fiber n c x` of a degree-`n`
tropical polynomial, for an *arbitrary* coefficient vector `c`:

* `exists_corner` — **every** tropical polynomial of degree `n ≥ 1` has a corner: a
  point where at least two monomials tie, together with a nearby point where exactly
  one monomial wins.  The corner is produced explicitly as
  `x* = max_{1 ≤ i ≤ n} (c 0 − c i)/i`, the largest slope-crossing with the constant
  monomial; at `x*` the index `0` and a maximiser `i₀` tie, and at `x* + 1` the index
  `0` wins alone.  No genericity or convexity assumption is used.
* `cornerSet_finite`, `cornerSet_ncard_le` — corners are rare: there are at most `n`
  of them, a consequence of the degree bound `multiplicity_sum_le` of `Core`.

Together these say the fibre family is *always* non-constant but only finitely so:
the fibre cardinality is `1` outside a set of size at most `n`, and `≥ 2` somewhere.
-/

namespace TropicalDependentFibers

open Finset

/-- **Corner existence.**  For every coefficient vector and every degree `n ≥ 1` there
is a point `x` where at least two monomials tie, while at `x + 1` the constant monomial
wins alone.  Hence the fibre family takes at least two different cardinalities. -/
theorem exists_corner {n : ℕ} (hn : 1 ≤ n) (c : ℕ → ℚ) :
    ∃ x : ℚ, 2 ≤ (fiber n c x).card ∧ fiber n c (x + 1) = {0} := by
  classical
  have hne : (Finset.Icc 1 n).Nonempty := ⟨1, Finset.mem_Icc.mpr ⟨le_refl 1, hn⟩⟩
  set g : ℕ → ℚ := fun i => (c 0 - c i) / (i : ℚ) with hg
  obtain ⟨i₀, hi₀mem, hi₀eq⟩ := Finset.exists_mem_eq_sup' hne g
  set x : ℚ := (Finset.Icc 1 n).sup' hne g with hx
  obtain ⟨hi₀one, hi₀n⟩ := Finset.mem_Icc.mp hi₀mem
  -- the constant monomial is a lower bound at `x`
  have key : ∀ i, 1 ≤ i → i ≤ n → c 0 ≤ c i + (i : ℚ) * x := by
    intro i h1 h2
    have hipos : (0 : ℚ) < (i : ℚ) := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one h1
    have hle : g i ≤ x := Finset.le_sup' g (Finset.mem_Icc.mpr ⟨h1, h2⟩)
    rw [hg] at hle
    simp only at hle
    rw [div_le_iff₀ hipos] at hle
    nlinarith
  -- and it is attained at the maximiser `i₀`
  have heq0 : c i₀ + (i₀ : ℚ) * x = c 0 := by
    have hipos : (0 : ℚ) < (i₀ : ℚ) := by
      exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hi₀one
    have : g i₀ = x := hi₀eq.symm
    rw [hg] at this
    simp only at this
    rw [div_eq_iff (ne_of_gt hipos)] at this
    nlinarith
  have hmin0 : ∀ j ≤ n, c 0 + ((0 : ℕ) : ℚ) * x ≤ c j + (j : ℚ) * x := by
    intro j hj
    rcases Nat.eq_zero_or_pos j with rfl | hjpos
    · simp
    · simpa using key j hjpos hj
  have h0mem : 0 ∈ fiber n c x := mem_fiber_iff.mpr ⟨Nat.zero_le n, hmin0⟩
  have hi₀mem' : i₀ ∈ fiber n c x := by
    refine mem_fiber_iff.mpr ⟨hi₀n, fun j hj => ?_⟩
    have := hmin0 j hj
    rw [heq0]
    simpa using this
  refine ⟨x, ?_, ?_⟩
  · have hsub : ({0, i₀} : Finset ℕ) ⊆ fiber n c x := by
      intro y hy
      rcases Finset.mem_insert.mp hy with rfl | hy'
      · exact h0mem
      · rw [Finset.mem_singleton] at hy'; exact hy' ▸ hi₀mem'
    have hcard : ({0, i₀} : Finset ℕ).card = 2 := by
      rw [Finset.card_insert_of_notMem (by simp; omega), Finset.card_singleton]
    calc (2 : ℕ) = ({0, i₀} : Finset ℕ).card := hcard.symm
      _ ≤ (fiber n c x).card := Finset.card_le_card hsub
  · -- just to the right of the corner, the constant monomial wins alone
    have hzero : ∀ j ≤ n, c 0 + ((0 : ℕ) : ℚ) * (x + 1) ≤ c j + (j : ℚ) * (x + 1) := by
      intro j hj
      rcases Nat.eq_zero_or_pos j with rfl | hjpos
      · simp
      · have h := key j hjpos hj
        have hjpos' : (0 : ℚ) < (j : ℚ) := by
          exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hjpos
        simp only [Nat.cast_zero, zero_mul, add_zero]
        nlinarith
    have h0mem' : 0 ∈ fiber n c (x + 1) := mem_fiber_iff.mpr ⟨Nat.zero_le n, hzero⟩
    refine Finset.eq_singleton_iff_unique_mem.mpr ⟨h0mem', fun y hy => ?_⟩
    by_contra hy0
    obtain ⟨hyn, hymin⟩ := mem_fiber_iff.mp hy
    have hypos : 1 ≤ y := Nat.one_le_iff_ne_zero.mpr hy0
    have hypos' : (0 : ℚ) < (y : ℚ) := by
      exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hypos
    have h := key y hypos hyn
    have h2 := hymin 0 (Nat.zero_le n)
    simp only [Nat.cast_zero, zero_mul, add_zero] at h2
    nlinarith

/-- **The family is never cardinality-constant.**  For `n ≥ 1` some fibre has at least
two elements and some fibre has exactly one, so two fibres have unequal cardinality. -/
theorem exists_unequal_fibers {n : ℕ} (hn : 1 ≤ n) (c : ℕ → ℚ) :
    ∃ x y : ℚ, (fiber n c x).card ≠ (fiber n c y).card := by
  obtain ⟨x, hx, hy⟩ := exists_corner hn c
  exact ⟨x, x + 1, by rw [hy]; simp; omega⟩

/-! ## Corners are rare -/

/-- The **corner set** of a tropical polynomial: the points where the fibre is not a
singleton, i.e. where at least two monomials tie. -/
def cornerSet (n : ℕ) (c : ℕ → ℚ) : Set ℚ := {x : ℚ | 2 ≤ (fiber n c x).card}

theorem one_le_sub_one_of_mem_cornerSet {n : ℕ} {c : ℕ → ℚ} {x : ℚ}
    (hx : x ∈ cornerSet n c) : 1 ≤ (fiber n c x).card - 1 := by
  have : 2 ≤ (fiber n c x).card := hx
  omega

/-- The corner set is finite: a degree-`n` tropical polynomial has finitely many
corners. -/
theorem cornerSet_finite (n : ℕ) (c : ℕ → ℚ) : (cornerSet n c).Finite := by
  by_contra hcon
  have hinf : (cornerSet n c).Infinite := hcon
  obtain ⟨t, hts, htc⟩ := hinf.exists_subset_card_eq (n + 1)
  have hsum : (n + 1 : ℕ) ≤ ∑ x ∈ t, ((fiber n c x).card - 1) := by
    calc (n + 1 : ℕ) = t.card := htc.symm
      _ = ∑ _x ∈ t, 1 := by simp
      _ ≤ ∑ x ∈ t, ((fiber n c x).card - 1) :=
        Finset.sum_le_sum fun x hx => one_le_sub_one_of_mem_cornerSet (hts hx)
  have := multiplicity_sum_le n c t
  omega

/-- **At most `n` corners.**  The number of points where the fibre is non-trivial is
bounded by the degree — the counting half of the tropical fundamental theorem. -/
theorem cornerSet_ncard_le (n : ℕ) (c : ℕ → ℚ) : (cornerSet n c).ncard ≤ n := by
  classical
  have hfin := cornerSet_finite n c
  set t := hfin.toFinset with ht
  have hcard : (cornerSet n c).ncard = t.card := Set.ncard_eq_toFinset_card _ hfin
  have hsum : t.card ≤ ∑ x ∈ t, ((fiber n c x).card - 1) := by
    calc t.card = ∑ _x ∈ t, 1 := by simp
      _ ≤ ∑ x ∈ t, ((fiber n c x).card - 1) :=
        Finset.sum_le_sum fun x hx =>
          one_le_sub_one_of_mem_cornerSet (by simpa [ht] using hx)
  have := multiplicity_sum_le n c t
  omega

end TropicalDependentFibers