import Mathlib
import Combinatorics.QuartetCodes

/-!
# The two-tree quartet threshold is exactly six leaves

`Combinatorics.QuartetCodesUpperBound` shows by Erdős–Szekeres that any two caterpillars on ten
leaves share a quartet, while `QuartetCodes.not_isAgreementThreshold_five_two` exhibits two
caterpillars on five leaves sharing none.  Here the upper end is pushed down to the truth: **six**
leaves already force a common quartet, so the two-tree threshold is exactly `6`.

The proof is the coding-theoretic restriction principle in action.  A quartet letter depends only on
the *relative order* of the four leaves, so restricting a leaf order to any six leaves produces a
genuine six-leaf codeword (`qcode_restrict`), and a six-leaf statement transfers to every larger
leaf set.  The six-leaf statement itself is reduced by the group action
`(π, ρ) ↦ (1, ρ π⁻¹)` to a single quantifier over `Sym(6)` and then decided by the kernel.

-- !-- Lab Notes -- !--
## Hypothesis (Hypothesizer)
Exhaustive computation says that all `720²` pairs of six-leaf caterpillars share a quartet, i.e.
`h(2) = 6`; the Erdős–Szekeres value `10` is an artefact of the proof method.

## Experiment (Experimenter)
Deciding `∀ π ρ : Sym(6), ∃ quartet` directly is `518400` pairs and is out of kernel reach.  Using
the right translation action of `Sym(6)` on pairs, the statement collapses to `720` cases
(`six_leaf_core`), which the kernel checks in about two minutes.  The transfer to `n ≥ 6` leaves
needs the rank permutation of an injective map (`rankPerm`) and the order-invariance of the ternary
letter (`code3_congr`).

## Analysis (Analyst)
The gain (from `10` down to `6`) comes entirely from *not* using Erdős–Szekeres: the quartet letter
is an order invariant, so a purely local six-leaf obstruction suffices.  The same mechanism should
sharpen the `k`-tree bound `3^{2^k}` if the corresponding finite statement can be decided for the
relevant window size.

## Critique (Critic)
`code3_congr` is stated with all twelve order comparisons, so it does not silently assume the four
leaves are distinct; `rankPerm` is built from an explicit rank function with a proved injectivity,
so the statement uses no choice beyond what `Equiv.ofBijective` needs.  The final theorem quantifies
over *all* pairs of leaf orders on *all* `n ≥ 6`, and the exhibited quartet is genuinely made of
four distinct leaves.
-/

open Finset

namespace QuartetCodes

section Restriction

variable {m n : ℕ}

/-- The ternary quartet letter depends only on the order relations among the four positions. -/
lemma code3_congr {p q r s p' q' r' s' : ℕ}
    (hpq : p < q ↔ p' < q') (hqp : q < p ↔ q' < p')
    (hpr : p < r ↔ p' < r') (hrp : r < p ↔ r' < p')
    (hps : p < s ↔ p' < s') (hsp : s < p ↔ s' < p')
    (hqr : q < r ↔ q' < r') (hrq : r < q ↔ r' < q')
    (hqs : q < s ↔ q' < s') (hsq : s < q ↔ s' < q')
    (hrs : r < s ↔ r' < s') (hsr : s < r ↔ s' < r') :
    code3 p q r s = code3 p' q' r' s' := by
  unfold code3
  simp only [max_lt_iff, lt_min_iff, hpq, hqp, hpr, hrp, hps, hsp, hqr, hrq, hqs, hsq, hrs, hsr]

/-- The rank of `i` among the values of `g`. -/
def rankOf (g : Fin m → Fin n) (i : Fin m) : ℕ :=
  ((Finset.univ : Finset (Fin m)).filter (fun j => (g j).val < (g i).val)).card

lemma rankOf_lt (g : Fin m → Fin n) (i : Fin m) : rankOf g i < m := by
  unfold rankOf
  have hsub : ((Finset.univ : Finset (Fin m)).filter (fun j => (g j).val < (g i).val))
      ⊆ (Finset.univ : Finset (Fin m)).erase i := by
    intro j hj
    rw [Finset.mem_filter] at hj
    refine Finset.mem_erase.2 ⟨?_, Finset.mem_univ _⟩
    rintro rfl
    exact absurd hj.2 (lt_irrefl _)
  have hcard := Finset.card_le_card hsub
  have : ((Finset.univ : Finset (Fin m)).erase i).card = m - 1 := by
    rw [Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ, Fintype.card_fin]
  have hm : 0 < m := i.pos
  omega

lemma rankOf_lt_of_lt {g : Fin m → Fin n} {i j : Fin m} (h : (g i).val < (g j).val) :
    rankOf g i < rankOf g j := by
  refine Finset.card_lt_card ⟨?_, ?_⟩
  · intro x hx
    rw [Finset.mem_filter] at hx ⊢
    exact ⟨hx.1, lt_trans hx.2 h⟩
  · intro hsub
    have hi : i ∈ (Finset.univ : Finset (Fin m)).filter (fun x => (g x).val < (g j).val) :=
      Finset.mem_filter.2 ⟨Finset.mem_univ _, h⟩
    have := hsub hi
    rw [Finset.mem_filter] at this
    exact absurd this.2 (lt_irrefl _)

lemma rankOf_lt_iff {g : Fin m → Fin n} (hg : Function.Injective g) (i j : Fin m) :
    rankOf g i < rankOf g j ↔ (g i).val < (g j).val := by
  constructor
  · intro h
    rcases lt_trichotomy (g i).val (g j).val with hlt | heq | hgt
    · exact hlt
    · exact absurd (congrArg (rankOf g) (hg (Fin.val_injective heq))) (Nat.ne_of_lt h)
    · exact absurd (rankOf_lt_of_lt hgt) (asymm h)
  · exact rankOf_lt_of_lt

/-- The permutation of `Fin m` recording the ranks of an injective map `g : Fin m → Fin n`. -/
noncomputable def rankPerm (g : Fin m → Fin n) (hg : Function.Injective g) :
    Equiv.Perm (Fin m) :=
  Equiv.ofBijective (fun i => (⟨rankOf g i, rankOf_lt g i⟩ : Fin m))
    (Finite.injective_iff_bijective.1 (by
      intro i j hij
      have h : rankOf g i = rankOf g j := congrArg Fin.val hij
      rcases lt_trichotomy (g i).val (g j).val with hlt | heq | hgt
      · exact absurd (rankOf_lt_of_lt hlt) (by omega)
      · exact hg (Fin.val_injective heq)
      · exact absurd (rankOf_lt_of_lt hgt) (by omega)))

lemma rankPerm_val {g : Fin m → Fin n} (hg : Function.Injective g) (i : Fin m) :
    ((rankPerm g hg) i).val = rankOf g i := rfl

/-- **Restriction principle.**  Reading a leaf order on `n` leaves along an injective map from
`Fin m` produces a leaf order on `m` leaves with the same quartet letters. -/
theorem qcode_restrict (π : Equiv.Perm (Fin n)) (f : Fin m → Fin n)
    (hf : Function.Injective f) :
    ∃ σ : Equiv.Perm (Fin m), ∀ a b c d : Fin m,
      qcode π (f a) (f b) (f c) (f d) = qcode σ a b c d := by
  have hg : Function.Injective (fun i : Fin m => π (f i)) :=
    fun x y hxy => hf (π.injective hxy)
  refine ⟨rankPerm (fun i => π (f i)) hg, ?_⟩
  intro a b c d
  have key : ∀ i j : Fin m,
      (π (f i)).val < (π (f j)).val ↔
        ((rankPerm (fun i => π (f i)) hg) i).val < ((rankPerm (fun i => π (f i)) hg) j).val := by
    intro i j
    rw [rankPerm_val, rankPerm_val]
    exact (rankOf_lt_iff hg i j).symm
  exact code3_congr (key a b) (key b a) (key a c) (key c a) (key a d) (key d a)
    (key b c) (key c b) (key b d) (key d b) (key c d) (key d c)

end Restriction

section SixLeaves

lemma qcode_perm_comp {m : ℕ} (τ σ : Equiv.Perm (Fin m)) (x y z w : Fin m) :
    qcode τ (σ x) (σ y) (σ z) (σ w) = qcode (τ * σ) x y z w := by
  simp [qcode, Equiv.Perm.mul_apply]

set_option maxRecDepth 10000000 in
set_option maxHeartbeats 4000000 in
/-- The decided core: every leaf order on six leaves shares a quartet with the identity order. -/
theorem six_leaf_core : ∀ υ : Equiv.Perm (Fin 6), ∃ a b c d : Fin 6,
    a ≠ b ∧ a ≠ c ∧ a ≠ d ∧ b ≠ c ∧ b ≠ d ∧ c ≠ d ∧
    qcode (1 : Equiv.Perm (Fin 6)) a b c d = qcode υ a b c d := by decide

/-- Any two leaf orders on six leaves share a quartet. -/
theorem six_leaf_pair (σ τ : Equiv.Perm (Fin 6)) :
    ∃ a b c d : Fin 6, a ≠ b ∧ a ≠ c ∧ a ≠ d ∧ b ≠ c ∧ b ≠ d ∧ c ≠ d ∧
      qcode σ a b c d = qcode τ a b c d := by
  obtain ⟨x, y, z, w, hxy, hxz, hxw, hyz, hyw, hzw, hcode⟩ := six_leaf_core (τ * σ⁻¹)
  refine ⟨σ⁻¹ x, σ⁻¹ y, σ⁻¹ z, σ⁻¹ w, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact fun h => hxy (σ⁻¹.injective h)
  · exact fun h => hxz (σ⁻¹.injective h)
  · exact fun h => hxw (σ⁻¹.injective h)
  · exact fun h => hyz (σ⁻¹.injective h)
  · exact fun h => hyw (σ⁻¹.injective h)
  · exact fun h => hzw (σ⁻¹.injective h)
  · rw [qcode_perm_comp σ σ⁻¹, qcode_perm_comp τ σ⁻¹, mul_inv_cancel]
    exact hcode

/-- **Sharp two-tree bound.**  Any two caterpillars on at least six leaves display a common
quartet.  With `not_isAgreementThreshold_five_two` this pins the two-tree threshold at exactly
six leaves. -/
theorem caterpillar_pair_common_quartet_six {n : ℕ} (hn : 6 ≤ n) (π ρ : Equiv.Perm (Fin n)) :
    ∃ a b c d : Fin n, a ≠ b ∧ a ≠ c ∧ a ≠ d ∧ b ≠ c ∧ b ≠ d ∧ c ≠ d ∧
      qcode π a b c d = qcode ρ a b c d := by
  have hf : Function.Injective (Fin.castLE hn : Fin 6 → Fin n) := Fin.castLE_injective hn
  obtain ⟨σ, hσ⟩ := qcode_restrict π (Fin.castLE hn) hf
  obtain ⟨τ, hτ⟩ := qcode_restrict ρ (Fin.castLE hn) hf
  obtain ⟨a, b, c, d, hab, hac, had, hbc, hbd, hcd, hcode⟩ := six_leaf_pair σ τ
  refine ⟨Fin.castLE hn a, Fin.castLE hn b, Fin.castLE hn c, Fin.castLE hn d, ?_, ?_, ?_, ?_, ?_,
    ?_, ?_⟩
  · exact fun h => hab (hf h)
  · exact fun h => hac (hf h)
  · exact fun h => had (hf h)
  · exact fun h => hbc (hf h)
  · exact fun h => hbd (hf h)
  · exact fun h => hcd (hf h)
  · rw [hσ a b c d, hτ a b c d]; exact hcode

end SixLeaves

end QuartetCodes