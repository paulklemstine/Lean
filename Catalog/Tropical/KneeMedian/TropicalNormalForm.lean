/-
# The median is a tropical (max,min)-polynomial

For a sample `x : Fin (2k+1) → α` in a linear order, the median is *exactly* the
`(max, min)`-polynomial

    `tropMedian x = ⨆_{|S| = k+1} ⨅_{i ∈ S} x i`

i.e. the maximum over all `(k+1)`-element index sets of the minimum of the sample on
that set.  Since `(⊔, ⊓) = (max, min)` is a commutative idempotent semiring on any
linear order (the *bounded tropical semiring*), this exhibits the median as a
homogeneous tropical polynomial of degree `k+1` in `2k+1` variables — a purely
algebraic normal form for a statistical quantity.

## Main results

* `sup_inf_le_of_isMedianIdx`, `le_tropMedian_of_isMedianIdx`, `tropMedian_eq` — the
  normal form: the counting median equals the max-of-mins polynomial.
* `isMedian_of_isMedianIdx` — bridge to the multiset-level `IsMedian` of
  `MedianEquivariance`, so the normal form transports the equivariance theorems.
* `tropMed3`, `tropMed3_eq_tropMedian`, `isMedianIdx_tropMed3` — the three-seed case:
  `med(a,b,c) = (a ⊓ b) ⊔ (b ⊓ c) ⊔ (a ⊓ c)`, and its dual form.
* `tropMed3_neg`, `tropMed3_add_const` — self-duality under order reversal and
  tropical homogeneity of degree one (translation equivariance).
* `tropMed3_nonexpansive` — the median of three is `1`-Lipschitz for the sup-norm,
  the quantitative robustness statement behind "the centre is the stable quantity".
-/
import Tropical.KneeMedian.MedianEquivariance

namespace Catalog.Tropical.KneeMedian

open Finset

variable {α : Type*} [LinearOrder α]

/-! ## The counting median of an indexed sample -/

/-- Index-level version of `IsMedian` for a sample of size `2k+1`. -/
structure IsMedianIdx (k : ℕ) (x : Fin (2 * k + 1) → α) (m : α) : Prop where
  mem : ∃ i, x i = m
  lower : k + 1 ≤ (univ.filter fun i => x i ≤ m).card
  upper : k + 1 ≤ (univ.filter fun i => m ≤ x i).card

/-- The index-level median is a median of the associated multiset, so all the
equivariance theory of `MedianEquivariance` applies to it. -/
theorem isMedian_of_isMedianIdx {k : ℕ} {x : Fin (2 * k + 1) → α} {m : α}
    (h : IsMedianIdx k x m) : IsMedian k (univ.val.map x) m := by
  classical
  obtain ⟨i, hi⟩ := h.mem
  refine ⟨?_, ?_, ?_⟩
  · exact Multiset.mem_map.mpr ⟨i, by simp, hi⟩
  · rw [card_filter_map]
    simpa [Finset.filter_val, Finset.card_def] using h.lower
  · rw [card_filter_map]
    simpa [Finset.filter_val, Finset.card_def] using h.upper

/-- Complementary counting: at most `k` sample entries can be `> m` when `m` is the median. -/
theorem card_filter_lt_of_isMedianIdx {k : ℕ} {x : Fin (2 * k + 1) → α} {m : α}
    (h : IsMedianIdx k x m) : (univ.filter fun i => m < x i).card ≤ k := by
  classical
  have hsplit := Finset.card_filter_add_card_filter_not
    (s := (univ : Finset (Fin (2 * k + 1)))) (p := fun i => x i ≤ m)
  have hcard : (univ : Finset (Fin (2 * k + 1))).card = 2 * k + 1 := by simp
  have hneg : (univ.filter fun i => ¬ x i ≤ m) = (univ.filter fun i => m < x i) := by
    apply Finset.filter_congr
    intro i _
    simp [not_le]
  rw [hneg, hcard] at hsplit
  have := h.lower
  omega

/-! ## The tropical polynomial -/

/-- The max-of-mins tropical polynomial of degree `k+1`:
`tropMedian x = ⨆_{|S| = k+1} ⨅_{i ∈ S} x i`. -/
noncomputable def tropMedian {k : ℕ} (x : Fin (2 * k + 1) → α) : α :=
  ((univ : Finset (Fin (2 * k + 1))).powersetCard (k + 1)).attach.sup'
    (by
      rw [Finset.attach_nonempty_iff, Finset.powersetCard_nonempty]
      simp; omega)
    (fun S => S.1.inf'
      (by
        have h := (Finset.mem_powersetCard.mp S.2).2
        exact Finset.card_pos.mp (by omega)) x)

/-- Every `(k+1)`-subset has a member with `x i ≤ m`: otherwise `k+1` entries would exceed
the median, contradicting the counting bound. -/
theorem exists_le_of_card_eq {k : ℕ} {x : Fin (2 * k + 1) → α} {m : α}
    (h : IsMedianIdx k x m) {S : Finset (Fin (2 * k + 1))} (hS : S.card = k + 1) :
    ∃ i ∈ S, x i ≤ m := by
  classical
  by_contra hcon
  push_neg at hcon
  have hsub : S ⊆ univ.filter fun i => m < x i := by
    intro i hi
    exact Finset.mem_filter.mpr ⟨Finset.mem_univ i, hcon i hi⟩
  have := Finset.card_le_card hsub
  have := card_filter_lt_of_isMedianIdx h
  omega

/-- Upper half of the normal form: every min over a `(k+1)`-set is `≤` the median. -/
theorem tropMedian_le_of_isMedianIdx {k : ℕ} {x : Fin (2 * k + 1) → α} {m : α}
    (h : IsMedianIdx k x m) : tropMedian x ≤ m := by
  classical
  apply Finset.sup'_le
  rintro ⟨S, hS⟩ -
  have hcard := (Finset.mem_powersetCard.mp hS).2
  obtain ⟨i, hiS, hi⟩ := exists_le_of_card_eq h hcard
  exact le_trans (Finset.inf'_le _ hiS) hi

/-- Lower half of the normal form: the `k+1` entries `≥ m` give a set whose min is `≥ m`. -/
theorem le_tropMedian_of_isMedianIdx {k : ℕ} {x : Fin (2 * k + 1) → α} {m : α}
    (h : IsMedianIdx k x m) : m ≤ tropMedian x := by
  classical
  obtain ⟨S, hSsub, hScard⟩ :=
    Finset.exists_subset_card_eq (s := univ.filter fun i => m ≤ x i) (n := k + 1) h.upper
  have hSmem : S ∈ (univ : Finset (Fin (2 * k + 1))).powersetCard (k + 1) :=
    Finset.mem_powersetCard.mpr ⟨Finset.subset_univ S, hScard⟩
  have hle : m ≤ S.inf' (Finset.card_pos.mp (by omega)) x := by
    apply Finset.le_inf'
    intro i hi
    exact (Finset.mem_filter.mp (hSsub hi)).2
  refine le_trans hle ?_
  exact Finset.le_sup' (f := fun S : {S // S ∈ (univ : Finset (Fin (2 * k + 1))).powersetCard (k+1)}
      => S.1.inf' (Finset.card_pos.mp (by
        have h := (Finset.mem_powersetCard.mp S.2).2; omega)) x)
    (Finset.mem_attach _ ⟨S, hSmem⟩)

/-- **Tropical normal form of the median.**  The median of an odd sample is the
max-of-mins tropical polynomial of degree `k+1`. -/
theorem tropMedian_eq {k : ℕ} {x : Fin (2 * k + 1) → α} {m : α} (h : IsMedianIdx k x m) :
    tropMedian x = m :=
  le_antisymm (tropMedian_le_of_isMedianIdx h) (le_tropMedian_of_isMedianIdx h)

/-! ## General threshold duality -/

/-- **Threshold duality (upper form).**  A value `v` is below the median of `2k+1` samples
exactly when at least `k+1` samples are `≥ v`: thresholding a median is a majority vote. -/
theorem le_tropMedian_iff {k : ℕ} (x : Fin (2 * k + 1) → α) (v : α) :
    v ≤ tropMedian x ↔ k + 1 ≤ (univ.filter fun i => v ≤ x i).card := by
  classical
  constructor
  · intro h
    rw [tropMedian, Finset.le_sup'_iff] at h
    obtain ⟨S, -, hS⟩ := h
    have hcard := (Finset.mem_powersetCard.mp S.2).2
    have hsub : S.1 ⊆ univ.filter fun i => v ≤ x i := by
      intro i hi
      exact Finset.mem_filter.mpr ⟨Finset.mem_univ i, le_trans hS (Finset.inf'_le _ hi)⟩
    calc k + 1 = S.1.card := hcard.symm
      _ ≤ _ := Finset.card_le_card hsub
  · intro h
    obtain ⟨S, hSsub, hScard⟩ :=
      Finset.exists_subset_card_eq (s := univ.filter fun i => v ≤ x i) (n := k + 1) h
    have hSmem : S ∈ (univ : Finset (Fin (2 * k + 1))).powersetCard (k + 1) :=
      Finset.mem_powersetCard.mpr ⟨Finset.subset_univ S, hScard⟩
    have hle : v ≤ S.inf' (Finset.card_pos.mp (by omega)) x := by
      apply Finset.le_inf'
      intro i hi
      exact (Finset.mem_filter.mp (hSsub hi)).2
    refine le_trans hle ?_
    exact Finset.le_sup'
      (f := fun S : {S // S ∈ (univ : Finset (Fin (2 * k + 1))).powersetCard (k + 1)} =>
        S.1.inf' (Finset.card_pos.mp (by
          have h := (Finset.mem_powersetCard.mp S.2).2; omega)) x)
      (Finset.mem_attach _ ⟨S, hSmem⟩)

/-- **Threshold duality (lower form).**  The median of `2k+1` samples is `≤ v` exactly when at
least `k+1` samples are `≤ v`. -/
theorem tropMedian_le_iff {k : ℕ} (x : Fin (2 * k + 1) → α) (v : α) :
    tropMedian x ≤ v ↔ k + 1 ≤ (univ.filter fun i => x i ≤ v).card := by
  classical
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    have hsplit := Finset.card_filter_add_card_filter_not
      (s := (univ : Finset (Fin (2 * k + 1)))) (p := fun i => x i ≤ v)
    have hcardu : (univ : Finset (Fin (2 * k + 1))).card = 2 * k + 1 := by simp
    rw [hcardu] at hsplit
    have hbig : k + 1 ≤ (univ.filter fun i => ¬ x i ≤ v).card := by omega
    obtain ⟨S, hSsub, hScard⟩ :=
      Finset.exists_subset_card_eq (s := univ.filter fun i => ¬ x i ≤ v) (n := k + 1) hbig
    have hSmem : S ∈ (univ : Finset (Fin (2 * k + 1))).powersetCard (k + 1) :=
      Finset.mem_powersetCard.mpr ⟨Finset.subset_univ S, hScard⟩
    have hlt : v < S.inf' (Finset.card_pos.mp (by omega)) x := by
      refine (Finset.lt_inf'_iff _).mpr ?_
      intro i hi
      exact lt_of_not_ge (Finset.mem_filter.mp (hSsub hi)).2
    have hsup : S.inf' (Finset.card_pos.mp (by omega)) x ≤ tropMedian x :=
      Finset.le_sup'
        (f := fun S : {S // S ∈ (univ : Finset (Fin (2 * k + 1))).powersetCard (k + 1)} =>
          S.1.inf' (Finset.card_pos.mp (by
            have h := (Finset.mem_powersetCard.mp S.2).2; omega)) x)
        (Finset.mem_attach _ ⟨S, hSmem⟩)
    exact absurd (lt_of_lt_of_le hlt (le_trans hsup h)) (lt_irrefl v)
  · intro h
    apply Finset.sup'_le
    rintro ⟨S, hS⟩ -
    have hcard := (Finset.mem_powersetCard.mp hS).2
    have hunion : (S ∪ univ.filter fun i => x i ≤ v).card ≤ 2 * k + 1 := by
      have := Finset.card_le_card (Finset.subset_univ (S ∪ univ.filter fun i => x i ≤ v))
      simpa using this
    have hinter := Finset.card_inter_add_card_union S (univ.filter fun i => x i ≤ v)
    have hpos : 0 < (S ∩ univ.filter fun i => x i ≤ v).card := by omega
    obtain ⟨i, hi⟩ := Finset.card_pos.mp hpos
    have hiS : i ∈ S := (Finset.mem_inter.mp hi).1
    have hiv : x i ≤ v := (Finset.mem_filter.mp (Finset.mem_inter.mp hi).2).2
    exact le_trans (Finset.inf'_le _ hiS) hiv

/-- The median is always one of the samples. -/
theorem tropMedian_mem_range {k : ℕ} (x : Fin (2 * k + 1) → α) : ∃ i, tropMedian x = x i := by
  classical
  obtain ⟨S, -, hS⟩ := Finset.exists_mem_eq_sup'
    (s := ((univ : Finset (Fin (2 * k + 1))).powersetCard (k + 1)).attach)
    (by
      rw [Finset.attach_nonempty_iff, Finset.powersetCard_nonempty]
      simp; omega)
    (fun S => S.1.inf' (Finset.card_pos.mp (by
      have h := (Finset.mem_powersetCard.mp S.2).2; omega)) x)
  obtain ⟨i, -, hi⟩ := Finset.exists_mem_eq_inf'
    (s := S.1) (Finset.card_pos.mp (by
      have h := (Finset.mem_powersetCard.mp S.2).2; omega)) x
  exact ⟨i, by rw [tropMedian, hS, hi]⟩

/-! ## The three-seed case -/

/-- Cardinality of a filtered subset of `Fin 3`, as an explicit sum of indicators. -/
theorem card_filter_fin3 (p : Fin 3 → Prop) [DecidablePred p] :
    (univ.filter p).card =
      (if p 0 then 1 else 0) + (if p 1 then 1 else 0) + (if p 2 then 1 else 0) := by
  rw [Finset.card_filter, Fin.sum_univ_three]

/-- The classical `(max, min)` normal form of the median of three. -/
def tropMed3 (a b c : α) : α := max (min a b) (max (min b c) (min a c))

/-- The dual `(min, max)` normal form: min-of-maxes.  Equality of the two normal forms is the
self-duality of the median under order reversal. -/
theorem tropMed3_eq_inf_sup (a b c : α) :
    tropMed3 a b c = min (max a b) (min (max b c) (max a c)) := by
  unfold tropMed3
  rcases le_total a b with hab | hab <;> rcases le_total b c with hbc | hbc <;>
    rcases le_total a c with hac | hac <;>
    simp only [min_def, max_def] <;> split_ifs <;> order

/-- The median of three is one of the three entries. -/
theorem tropMed3_eq_or (a b c : α) :
    tropMed3 a b c = a ∨ tropMed3 a b c = b ∨ tropMed3 a b c = c := by
  unfold tropMed3
  rcases le_total a b with hab | hab <;> rcases le_total b c with hbc | hbc <;>
    rcases le_total a c with hac | hac <;>
    simp only [min_def, max_def] <;> split_ifs <;> simp_all

/-- `tropMed3` is the counting median of the three-element sample: the tropical polynomial
and the statistical definition agree. -/
theorem isMedianIdx_tropMed3 (a b c : α) :
    IsMedianIdx 1 ![a, b, c] (tropMed3 a b c) := by
  classical
  set m := tropMed3 a b c with hm
  have hab_le : min a b ≤ m := le_max_left _ _
  have hbc_le : min b c ≤ m := le_trans (le_max_left _ _) (le_max_right _ _)
  have hac_le : min a c ≤ m := le_trans (le_max_right _ _) (le_max_right _ _)
  have hdual : m = min (max a b) (min (max b c) (max a c)) := by
    rw [hm]; exact tropMed3_eq_inf_sup a b c
  have hle_ab : m ≤ max a b := by rw [hdual]; exact min_le_left _ _
  have hle_bc : m ≤ max b c := by
    rw [hdual]; exact le_trans (min_le_right _ _) (min_le_left _ _)
  have hle_ac : m ≤ max a c := by
    rw [hdual]; exact le_trans (min_le_right _ _) (min_le_right _ _)
  refine ⟨?_, ?_, ?_⟩
  · rcases tropMed3_eq_or a b c with h | h | h
    · exact ⟨0, by simpa using h.symm⟩
    · exact ⟨1, by simpa using h.symm⟩
    · exact ⟨2, by simpa using h.symm⟩
  · rw [card_filter_fin3]
    simp only [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two,
      Matrix.tail_cons]
    rcases le_or_gt a m with h1 | h1
    · rcases le_or_gt b m with h2 | h2
      · simp only [if_pos h1, if_pos h2]; split_ifs <;> omega
      · rcases le_or_gt c m with h3 | h3
        · simp only [if_pos h1, if_pos h3]; split_ifs <;> omega
        · exact absurd hbc_le (by
            rcases min_le_iff.mp hbc_le with h | h
            exacts [absurd h (not_le.mpr h2), absurd h (not_le.mpr h3)])
    · rcases le_or_gt b m with h2 | h2
      · rcases le_or_gt c m with h3 | h3
        · simp only [if_pos h2, if_pos h3]; split_ifs <;> omega
        · exact absurd hac_le (by
            rcases min_le_iff.mp hac_le with h | h
            exacts [absurd h (not_le.mpr h1), absurd h (not_le.mpr h3)])
      · exact absurd hab_le (by
          rcases min_le_iff.mp hab_le with h | h
          exacts [absurd h (not_le.mpr h1), absurd h (not_le.mpr h2)])
  · rw [card_filter_fin3]
    simp only [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two,
      Matrix.tail_cons]
    rcases le_or_gt m a with h1 | h1
    · rcases le_or_gt m b with h2 | h2
      · simp only [if_pos h1, if_pos h2]; split_ifs <;> omega
      · rcases le_or_gt m c with h3 | h3
        · simp only [if_pos h1, if_pos h3]; split_ifs <;> omega
        · exact absurd hle_bc (by
            rcases le_max_iff.mp hle_bc with h | h
            exacts [absurd h (not_le.mpr h2), absurd h (not_le.mpr h3)])
    · rcases le_or_gt m b with h2 | h2
      · rcases le_or_gt m c with h3 | h3
        · simp only [if_pos h2, if_pos h3]; split_ifs <;> omega
        · exact absurd hle_ac (by
            rcases le_max_iff.mp hle_ac with h | h
            exacts [absurd h (not_le.mpr h1), absurd h (not_le.mpr h3)])
      · exact absurd hle_ab (by
          rcases le_max_iff.mp hle_ab with h | h
          exacts [absurd h (not_le.mpr h1), absurd h (not_le.mpr h2)])

/-- Specialisation of the normal form: for three seeds the general max-of-mins polynomial is
the classical `(a ⊓ b) ⊔ (b ⊓ c) ⊔ (a ⊓ c)`. -/
theorem tropMedian_three (a b c : α) : tropMedian (k := 1) ![a, b, c] = tropMed3 a b c :=
  tropMedian_eq (isMedianIdx_tropMed3 a b c)

/-! ## Elementary bounds and symmetry of the median of three -/

/-- The median of three is symmetric in its first two arguments. -/
theorem tropMed3_swap12 (a b c : α) : tropMed3 a b c = tropMed3 b a c := by
  simp only [tropMed3, min_def, max_def]; split_ifs <;> order

/-- The median of three is symmetric in its last two arguments. -/
theorem tropMed3_swap23 (a b c : α) : tropMed3 a b c = tropMed3 a c b := by
  simp only [tropMed3, min_def, max_def]; split_ifs <;> order

/-- The median lies above the minimum. -/
theorem min_le_tropMed3 (a b c : α) : min a (min b c) ≤ tropMed3 a b c := by
  simp only [tropMed3, min_def, max_def]; split_ifs <;> order

/-- The median lies below the maximum. -/
theorem tropMed3_le_max (a b c : α) : tropMed3 a b c ≤ max a (max b c) := by
  simp only [tropMed3, min_def, max_def]; split_ifs <;> order

/-! ## Threshold duality: the median commutes with thresholding -/

/-- A threshold is passed by the median exactly when it is passed by at least two of the three
entries: thresholding turns the median into the majority vote. -/
theorem le_tropMed3_iff (v a b c : α) :
    v ≤ tropMed3 a b c ↔ (v ≤ a ∧ v ≤ b) ∨ (v ≤ b ∧ v ≤ c) ∨ (v ≤ a ∧ v ≤ c) := by
  simp [tropMed3]

/-- Dual threshold duality: the median is below `v` exactly when at least two entries are. -/
theorem tropMed3_le_iff (v a b c : α) :
    tropMed3 a b c ≤ v ↔ (a ≤ v ∧ b ≤ v) ∨ (b ≤ v ∧ c ≤ v) ∨ (a ≤ v ∧ c ≤ v) := by
  simp only [tropMed3, max_le_iff, min_le_iff]
  constructor
  · rintro ⟨hab, hbc, hac⟩
    rcases hab with h | h
    · rcases hbc with h' | h'
      · exact Or.inl ⟨h, h'⟩
      · exact Or.inr (Or.inr ⟨h, h'⟩)
    · rcases hac with h' | h'
      · exact Or.inl ⟨h', h⟩
      · exact Or.inr (Or.inl ⟨h, h'⟩)
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩) <;>
      exact ⟨by tauto, by tauto, by tauto⟩

/-! ## The stability interval of the median -/

/-- **Median stability interval.**  With two of the three seeds pinned at `b < c`, the median
stays at `b` **exactly** on the ray `x ≤ b`; any third value strictly above `b` moves the
centre.  (In particular a third value strictly between `b` and `c` already shifts the median,
so "only values `≥ c` move it" is false.) -/
theorem tropMed3_stable_iff {b c : α} (hbc : b < c) (x : α) :
    tropMed3 x b c = b ↔ x ≤ b := by
  constructor
  · intro h
    by_contra hx
    push_neg at hx
    have hlt : b < min x c := lt_min hx hbc
    have hle : min x c ≤ tropMed3 x b c :=
      le_trans (le_max_right _ _) (le_max_right _ _)
    rw [h] at hle
    exact absurd (lt_of_lt_of_le hlt hle) (lt_irrefl b)
  · intro hx
    have hxc : x ≤ c := le_trans hx (le_of_lt hbc)
    simp only [tropMed3, min_def, max_def]
    split_ifs <;> order

/-! ## Tropical algebra of the median polynomial -/

/-- The max-of-mins polynomial is monotone in every variable (a tropical polynomial with
nonnegative "coefficients" is order preserving). -/
theorem tropMedian_mono {k : ℕ} {x y : Fin (2 * k + 1) → α} (h : ∀ i, x i ≤ y i) :
    tropMedian x ≤ tropMedian y := by
  classical
  apply Finset.sup'_le
  intro S _
  refine le_trans ?_ (Finset.le_sup' _ (Finset.mem_attach _ S))
  apply Finset.le_inf'
  intro i hi
  exact le_trans (Finset.inf'_le _ hi) (h i)

/-- Monotonicity of the median of three in each argument. -/
theorem tropMed3_mono {a b c a' b' c' : α} (ha : a ≤ a') (hb : b ≤ b') (hc : c ≤ c') :
    tropMed3 a b c ≤ tropMed3 a' b' c' :=
  max_le_max (min_le_min ha hb) (max_le_max (min_le_min hb hc) (min_le_min ha hc))

section Group

variable {G : Type*} [LinearOrder G] [AddCommGroup G] [IsOrderedAddMonoid G]

/-- **Tropical homogeneity of degree one**: the median commutes with translations, i.e. it is
"tropically linear" — in min-plus language, adding a constant to every input adds it to the
output. -/
theorem tropMed3_add_const (a b c t : G) :
    tropMed3 (a + t) (b + t) (c + t) = tropMed3 a b c + t := by
  simp [tropMed3, min_add_add_right, max_add_add_right]

/-- **Self-duality under order reversal**: negating the sample negates the median.  Equivalently,
the max-of-mins polynomial and the min-of-maxes polynomial are exchanged by `x ↦ -x`. -/
theorem tropMed3_neg (a b c : G) : tropMed3 (-a) (-b) (-c) = -tropMed3 a b c := by
  rw [tropMed3_eq_inf_sup a b c]
  simp [tropMed3, neg_inf, neg_sup]

end Group

/-- **Nonexpansiveness (robustness).**  The median of three is `1`-Lipschitz for the sup-norm:
perturbing the sample by at most `d` in each coordinate moves the median by at most `d`.
This is the quantitative form of "the centre is the stable quantity". -/
theorem tropMed3_nonexpansive (a b c a' b' c' : ℝ) :
    |tropMed3 a b c - tropMed3 a' b' c'| ≤ max |a - a'| (max |b - b'| |c - c'|) := by
  set d : ℝ := max |a - a'| (max |b - b'| |c - c'|) with hd
  have hda : |a - a'| ≤ d := le_max_left _ _
  have hdb : |b - b'| ≤ d := le_trans (le_max_left _ _) (le_max_right _ _)
  have hdc : |c - c'| ≤ d := le_trans (le_max_right _ _) (le_max_right _ _)
  have h1 : a ≤ a' + d := by
    have := (abs_le.mp hda).2; linarith
  have h2 : b ≤ b' + d := by
    have := (abs_le.mp hdb).2; linarith
  have h3 : c ≤ c' + d := by
    have := (abs_le.mp hdc).2; linarith
  have h1' : a' ≤ a + d := by
    have := (abs_le.mp hda).1; linarith
  have h2' : b' ≤ b + d := by
    have := (abs_le.mp hdb).1; linarith
  have h3' : c' ≤ c + d := by
    have := (abs_le.mp hdc).1; linarith
  have key : tropMed3 a b c ≤ tropMed3 a' b' c' + d := by
    calc tropMed3 a b c ≤ tropMed3 (a' + d) (b' + d) (c' + d) := tropMed3_mono h1 h2 h3
      _ = tropMed3 a' b' c' + d := tropMed3_add_const a' b' c' d
  have key' : tropMed3 a' b' c' ≤ tropMed3 a b c + d := by
    calc tropMed3 a' b' c' ≤ tropMed3 (a + d) (b + d) (c + d) := tropMed3_mono h1' h2' h3'
      _ = tropMed3 a b c + d := tropMed3_add_const a b c d
  rw [abs_sub_le_iff]
  constructor <;> linarith

end Catalog.Tropical.KneeMedian