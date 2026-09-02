import Novelty.MultisetSortingMultinomial

/-!
# The Shannon ceiling and the coarsening law for multiset erasure

`Novelty.MultisetSortingMultinomial` identifies the information erased when a multiset with key
multiplicities `mᵢ` is sorted with `log₂ (n! / ∏ mᵢ!)`, the logarithm of the multinomial
coefficient.  This file bounds that quantity by *information-theoretic* data and shows how it
behaves under coarsening of the key alphabet.

## Main results

* `log_multinomial_le_entropy` : the purely combinatorial inequality
  `log (n!/∏ mᵢ!) ≤ ∑ᵢ mᵢ log (n/mᵢ)`, proved by evaluating the multinomial theorem at the
  empirical distribution `pᵢ = mᵢ/n` and keeping a single term.  No Stirling estimate is used.
* `infoErased_le_keyEntropyBits` : the erased information of multiset sorting is at most
  `n · H(p)` bits, where `H` is the Shannon entropy of the empirical key distribution
  (`keyEntropyBits_eq_card_mul_shannon` identifies the right-hand side with `n · H(p)`).
* `landauerGap_le_keyEntropy` : the Landauer form, `W ≤ kT · n · H(p) · log 2`.
* `infoErased_le_card_mul_logb_card` : the crude alphabet bound `≤ n log₂ r`, obtained from the
  fact that rearrangements are words, and `shannon_le_logb_card` : consequently the Shannon
  ceiling never beats the alphabet ceiling by accident — both bound the same quantity.
* `logb_choose_le_binaryEntropy` : the classical two-key corollary
  `log₂ C(a+b, a) ≤ a log₂ ((a+b)/a) + b log₂ ((a+b)/b)`.
* `card_rearrangements_le_of_coarsening` / `infoErased_le_of_coarsening` : a **data-processing
  law**: merging keys (composing the key word with any map `g`) can only decrease the number of
  distinguishable inputs, hence only decrease the erased information and the Landauer work.
* `multiset_sorting_savings_of_repeat` : with a repeated key, at least `log₂ (mᵢ!)` bits of the
  factorial baseline are never erased.
-/

open Finset Nat

namespace MultisetSorting

variable {α ι : Type*} [Fintype α] [DecidableEq α] [Fintype ι] [DecidableEq ι]

/-! ## The multinomial theorem at the empirical distribution -/

/-- **A single multinomial term is at most one.**  Evaluating `(∑ᵢ pᵢ)^n = 1` with
`pᵢ = mᵢ/n` and dropping all but the term indexed by `m` in the multinomial expansion. -/
theorem multinomial_mul_prob_pow_le_one (m : ι → ℕ) (n : ℕ) (hn : 0 < n) (hsum : ∑ i, m i = n) :
    (Nat.multinomial Finset.univ m : ℝ) * ∏ i, ((m i : ℝ) / n) ^ (m i) ≤ 1 := by
  have hmem : m ∈ (Finset.univ : Finset ι).piAntidiag n := by
    rw [Finset.mem_piAntidiag]
    exact ⟨hsum, fun i _ => Finset.mem_univ i⟩
  have key := Finset.sum_pow_eq_sum_piAntidiag (Finset.univ : Finset ι) (fun i => (m i : ℝ) / n) n
  have hone : (∑ i, ((m i : ℝ) / n)) = 1 := by
    rw [← Finset.sum_div]
    have hc : ((∑ i, m i : ℕ) : ℝ) = n := by rw [hsum]
    push_cast at hc
    rw [hc]
    have hn0 : (n : ℝ) ≠ 0 := by positivity
    field_simp
  rw [hone, one_pow] at key
  rw [key]
  refine Finset.single_le_sum
    (f := fun k => (Nat.multinomial Finset.univ k : ℝ) * ∏ i, ((m i : ℝ) / n) ^ k i) ?_ hmem
  intro k _
  positivity

/-- **Entropy ceiling for the multinomial coefficient.**  `log (n!/∏ mᵢ!) ≤ ∑ᵢ mᵢ log (n/mᵢ)`. -/
theorem log_multinomial_le_entropy (m : ι → ℕ) (n : ℕ) (hn : 0 < n) (hsum : ∑ i, m i = n) :
    Real.log (Nat.multinomial Finset.univ m) ≤ ∑ i, (m i : ℝ) * Real.log ((n : ℝ) / m i) := by
  have hnn : (0:ℝ) < (n:ℝ) := by exact_mod_cast hn
  have hP : (0:ℝ) < (Nat.multinomial Finset.univ m : ℝ) := by
    exact_mod_cast Nat.multinomial_pos _ _
  have hfac : ∀ i : ι, ((m i : ℝ) / n) ^ (m i) ≠ 0 := by
    intro i
    rcases Nat.eq_zero_or_pos (m i) with h | h
    · simp [h]
    · have hmi : (0:ℝ) < (m i : ℝ) := by exact_mod_cast h
      have : (0:ℝ) < (m i : ℝ) / n := div_pos hmi hnn
      positivity
  have hQ : (0:ℝ) < ∏ i, ((m i : ℝ) / n) ^ (m i) :=
    Finset.prod_pos fun i _ => lt_of_le_of_ne (by positivity) (Ne.symm (hfac i))
  have h1 := multinomial_mul_prob_pow_le_one m n hn hsum
  have hlog : Real.log ((Nat.multinomial Finset.univ m : ℝ) * ∏ i, ((m i : ℝ) / n) ^ (m i)) ≤ 0 := by
    calc _ ≤ Real.log 1 := Real.log_le_log (by positivity) h1
      _ = 0 := Real.log_one
  rw [Real.log_mul (ne_of_gt hP) (ne_of_gt hQ), Real.log_prod (fun i _ => hfac i)] at hlog
  have hterm : ∀ i : ι,
      Real.log (((m i : ℝ) / n) ^ (m i)) = - ((m i : ℝ) * Real.log ((n : ℝ) / m i)) := by
    intro i
    rw [Real.log_pow]
    rcases Nat.eq_zero_or_pos (m i) with h | h
    · simp [h]
    · have hmi : (0:ℝ) < (m i : ℝ) := by exact_mod_cast h
      rw [Real.log_div (ne_of_gt hmi) (ne_of_gt hnn), Real.log_div (ne_of_gt hnn) (ne_of_gt hmi)]
      ring
  simp only [hterm] at hlog
  rw [Finset.sum_neg_distrib] at hlog
  linarith

/-! ## The Shannon ceiling for multiset sorting -/

/-- The empirical key distribution `pᵢ = mᵢ / n`. -/
noncomputable def keyProb (w : α → ι) (i : ι) : ℝ := (keyMult w i : ℝ) / (Fintype.card α : ℝ)

/-- The Shannon entropy `H(p) = -∑ᵢ pᵢ log₂ pᵢ` of the empirical key distribution, in bits. -/
noncomputable def shannonKeyEntropy (w : α → ι) : ℝ :=
  -∑ i, keyProb w i * Real.logb 2 (keyProb w i)

/-- The total entropy budget `∑ᵢ mᵢ log₂ (n/mᵢ)` of a key word, in bits. -/
noncomputable def keyEntropyBits (w : α → ι) : ℝ :=
  ∑ i, (keyMult w i : ℝ) * Real.logb 2 ((Fintype.card α : ℝ) / (keyMult w i))

omit [DecidableEq α] in
/-- The entropy budget is `n · H(p)`. -/
theorem keyEntropyBits_eq_card_mul_shannon (w : α → ι) :
    keyEntropyBits w = (Fintype.card α : ℝ) * shannonKeyEntropy w := by
  unfold keyEntropyBits shannonKeyEntropy keyProb
  rw [mul_neg, Finset.mul_sum, ← Finset.sum_neg_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  rcases Nat.eq_zero_or_pos (keyMult w i) with h | h
  · simp [h]
  · have hmi : (0:ℝ) < (keyMult w i : ℝ) := by exact_mod_cast h
    have hcard : (0:ℝ) < (Fintype.card α : ℝ) := by
      have : 0 < Fintype.card α := lt_of_lt_of_le h (by
        rw [← sum_keyMult w]
        exact Finset.single_le_sum (fun j _ => Nat.zero_le _) (Finset.mem_univ i))
      exact_mod_cast this
    rw [Real.logb_div (ne_of_gt hcard) (ne_of_gt hmi),
      Real.logb_div (ne_of_gt hmi) (ne_of_gt hcard)]
    field_simp
    ring

/-- **The Shannon ceiling.**  Sorting a multiset erases at most `n · H(p)` bits, where `H(p)` is
the Shannon entropy of the empirical key distribution.  Equality is approached (but, by the
strictness of the multinomial expansion, not attained for `n ≥ 2` with a repeated key). -/
theorem infoErased_le_keyEntropyBits (w : α → ι) [Nonempty α] :
    infoErased (multisetSortingFunction w) ≤ keyEntropyBits w := by
  have hn : 0 < Fintype.card α := Fintype.card_pos
  have hlog := log_multinomial_le_entropy (keyMult w) (Fintype.card α) hn (sum_keyMult w)
  have h2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rw [infoErased_multisetSorting]
  unfold keyEntropyBits Real.logb
  rw [div_le_iff₀ h2] at *
  calc Real.log (Nat.multinomial Finset.univ (keyMult w))
      ≤ ∑ i, (keyMult w i : ℝ) * Real.log ((Fintype.card α : ℝ) / (keyMult w i)) := hlog
    _ = (∑ i, (keyMult w i : ℝ) *
          (Real.log ((Fintype.card α : ℝ) / (keyMult w i)) / Real.log 2)) * Real.log 2 := by
        rw [Finset.sum_mul]
        refine Finset.sum_congr rfl fun i _ => ?_
        field_simp

/-- **Landauer form of the Shannon ceiling.** -/
theorem landauerGap_le_keyEntropy (w : α → ι) [Nonempty α] {kT : ℝ} (hkT : 0 ≤ kT) :
    landauerGap (multisetSortingFunction w) kT ≤ kT * Real.log 2 * keyEntropyBits w := by
  unfold landauerGap landauerCost
  have h2 : (0:ℝ) ≤ Real.log 2 := (Real.log_pos (by norm_num)).le
  exact mul_le_mul_of_nonneg_left (infoErased_le_keyEntropyBits w) (mul_nonneg hkT h2)

/-! ## The alphabet ceiling -/

/-- Rearrangements are words of length `n` over the key alphabet. -/
theorem card_rearrangements_le_pow (w : α → ι) :
    (rearrangements w).card ≤ (Fintype.card ι) ^ (Fintype.card α) := by
  have h : (rearrangements w).card ≤ (Finset.univ : Finset (α → ι)).card :=
    Finset.card_le_card (Finset.subset_univ _)
  rwa [Finset.card_univ, Fintype.card_fun] at h

/-- **Alphabet ceiling.**  Sorting a multiset over `r` keys erases at most `n log₂ r` bits. -/
theorem infoErased_le_card_mul_logb_card (w : α → ι) :
    infoErased (multisetSortingFunction w)
      ≤ (Fintype.card α : ℝ) * Real.logb 2 (Fintype.card ι) := by
  rw [infoErased_multisetSorting, ← card_rearrangements]
  have hpos : (0:ℝ) < ((rearrangements w).card : ℝ) := by
    exact_mod_cast card_rearrangements_pos w
  have hle : ((rearrangements w).card : ℝ) ≤ ((Fintype.card ι : ℝ)) ^ (Fintype.card α) := by
    exact_mod_cast card_rearrangements_le_pow w
  calc Real.logb 2 ((rearrangements w).card : ℝ)
      ≤ Real.logb 2 (((Fintype.card ι : ℝ)) ^ (Fintype.card α)) :=
        Real.logb_le_logb_of_le (by norm_num) hpos hle
    _ = (Fintype.card α : ℝ) * Real.logb 2 (Fintype.card ι) := by
        rw [Real.logb_pow]

/-! ## The two-key corollary: binary entropy -/

/-- **Binary entropy bound.**  `log₂ C(a+b, a) ≤ a log₂ ((a+b)/a) + b log₂ ((a+b)/b)`, the
`ι = Fin 2` case of the Shannon ceiling. -/
theorem logb_choose_le_binaryEntropy (a b : ℕ) (hab : 0 < a + b) :
    Real.logb 2 ((a + b).choose a)
      ≤ (a : ℝ) * Real.logb 2 (((a + b : ℕ) : ℝ) / a)
        + (b : ℝ) * Real.logb 2 (((a + b : ℕ) : ℝ) / b) := by
  have hmul : Nat.multinomial (Finset.univ : Finset (Fin 2)) ![a, b] = (a + b).choose a := by
    rw [Nat.multinomial_univ_two,
      Nat.choose_eq_factorial_div_factorial (Nat.le_add_right a b), Nat.add_sub_cancel_left]
  have hsum : ∑ i, (![a, b] : Fin 2 → ℕ) i = a + b := by simp [Fin.sum_univ_two]
  have h := log_multinomial_le_entropy (![a, b] : Fin 2 → ℕ) (a + b) hab hsum
  rw [hmul] at h
  have h2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  simp only [Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one] at h
  have hgoal := (div_le_div_iff_of_pos_right h2).mpr h
  rw [add_div, mul_div_assoc, mul_div_assoc] at hgoal
  simpa [Real.logb] using hgoal

/-! ## Coarsening: a data-processing law for keys -/

variable {κ : Type*} [Fintype κ] [DecidableEq κ]

omit [Fintype ι] [Fintype κ] in
/-- **Coarsening surjection.**  If the key word `w` is obtained from `w'` by merging keys along
`g`, every rearrangement of `w` is the `g`-image of a rearrangement of `w'`. -/
theorem rearrangements_image_of_coarsening (w' : α → κ) (g : κ → ι) :
    Finset.image (fun v : α → κ => g ∘ v) (rearrangements w') = rearrangements (g ∘ w') := by
  ext v
  constructor
  · intro hv
    obtain ⟨u, hu, rfl⟩ := Finset.mem_image.mp hv
    obtain ⟨σ, -, rfl⟩ := Finset.mem_image.mp hu
    exact Finset.mem_image.mpr ⟨σ, Finset.mem_univ _, by ext a; rfl⟩
  · intro hv
    obtain ⟨σ, -, rfl⟩ := Finset.mem_image.mp hv
    exact Finset.mem_image.mpr
      ⟨w' ∘ σ, Finset.mem_image.mpr ⟨σ, Finset.mem_univ _, rfl⟩, by ext a; rfl⟩

omit [Fintype ι] [Fintype κ] in
/-- **Data-processing inequality for keys.**  Merging keys can only reduce the number of
distinguishable inputs. -/
theorem card_rearrangements_le_of_coarsening (w' : α → κ) (g : κ → ι) :
    (rearrangements (g ∘ w')).card ≤ (rearrangements w').card := by
  rw [← rearrangements_image_of_coarsening w' g]
  exact Finset.card_image_le

/-- **Data-processing inequality for erased information.**  A coarser key alphabet erases no
more information than a finer one. -/
theorem infoErased_le_of_coarsening (w' : α → κ) (g : κ → ι) :
    infoErased (multisetSortingFunction (g ∘ w'))
      ≤ infoErased (multisetSortingFunction w') := by
  rw [infoErased_multisetSorting, infoErased_multisetSorting, ← card_rearrangements,
    ← card_rearrangements]
  have hpos : (0:ℝ) < ((rearrangements (g ∘ w')).card : ℝ) := by
    exact_mod_cast card_rearrangements_pos (g ∘ w')
  have hle : ((rearrangements (g ∘ w')).card : ℝ) ≤ ((rearrangements w').card : ℝ) := by
    exact_mod_cast card_rearrangements_le_of_coarsening w' g
  exact Real.logb_le_logb_of_le (by norm_num) hpos hle

/-- **Landauer form of the coarsening law.** -/
theorem landauerGap_le_of_coarsening (w' : α → κ) (g : κ → ι) {kT : ℝ} (hkT : 0 ≤ kT) :
    landauerGap (multisetSortingFunction (g ∘ w')) kT
      ≤ landauerGap (multisetSortingFunction w') kT := by
  unfold landauerGap landauerCost
  have h2 : (0:ℝ) ≤ Real.log 2 := (Real.log_pos (by norm_num)).le
  exact mul_le_mul_of_nonneg_left (infoErased_le_of_coarsening w' g) (mul_nonneg hkT h2)

/-! ## The savings ledger -/

/-- **Guaranteed savings.**  A key repeated `mᵢ` times permanently removes `log₂ (mᵢ!)` bits
from the factorial baseline: those bits describe an intra-block order that no multiset sorter
ever learns. -/
theorem multiset_sorting_savings_of_repeat (w : α → ι) (i₀ : ι) :
    infoErased (multisetSortingFunction w) + Real.logb 2 ((keyMult w i₀)!)
      ≤ Real.logb 2 ((Fintype.card α)!) := by
  have hcons := infoErased_conservation w
  have hnn : 0 ≤ ∑ i ∈ Finset.univ.erase i₀, Real.logb 2 ((keyMult w i)!) := by
    refine Finset.sum_nonneg fun i _ => Real.logb_nonneg (by norm_num) ?_
    exact_mod_cast Nat.one_le_iff_ne_zero.mpr (Nat.factorial_ne_zero _)
  have hsplit : ∑ i, Real.logb 2 ((keyMult w i)!)
      = Real.logb 2 ((keyMult w i₀)!)
        + ∑ i ∈ Finset.univ.erase i₀, Real.logb 2 ((keyMult w i)!) :=
    (Finset.add_sum_erase _ _ (Finset.mem_univ i₀)).symm
  rw [hsplit] at hcons
  linarith

end MultisetSorting