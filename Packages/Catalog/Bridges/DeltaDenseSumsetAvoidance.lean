/-
# δ-dense sets avoiding large arithmetic sumsets

This file develops, from scratch, a rigorous finitary construction related to the
sharpness of "sumset in a dense set" theorems (Kra–Moreira–Richter–Robertson type
statements, whose finitary form predicts that a set `S ⊆ [n]` of density `δ` should
contain a sumset `A + B` with `min(|A|,|B|) ≍ log n / log (1/δ)`).

The content here is the *sharpness* side.  For every `0 < δ < 1` and every sufficiently
large `n` we construct a set `S ⊆ [n]` with `|S| ≥ δ n` such that

* `S` contains **no** arithmetic progression of length `(5/2)·log n / log (1/δ)`
  (`DeltaDense.exists_dense_no_ap`),
* `S` contains **no** sumset `A + B` with `A` an arbitrary nonempty finite set and `B` an
  arithmetic progression of length at least `(5/2)·log n / log (1/δ)`
  (`DeltaDense.exists_dense_no_sumset_with_ap`), and
* `S` contains **no** sumset `A + B` where `A` and `B` are arithmetic progressions —
  with *arbitrary, possibly different* positive common differences — of common length
  `k ≥ 3 log n / log (1/δ)`
  (`DeltaDense.exists_dense_avoiding_ap_sumsets`, and its asymptotic packaging
  `DeltaDense.eventually_exists_dense_avoiding_ap_sumsets`).

The second statement realises the constant `C(δ) = 3` from the conjectural picture: `3`
is exactly the number of parameters `(t, d₁, d₂)` needed to describe the "L-shaped"
witness `{t, t+d₁, …, t+(k-1)d₁} ∪ {t+(k-1)d₁, …, t+(k-1)d₁+(k-1)d₂}` of `2k-1` elements
that any such sumset must contain, so the first-moment union bound costs `n³`.

The proof is a purely counting ("derandomised probabilistic method") argument over the
family of `m`-element subsets of `[n]`:

* `DeltaDense.choose_ratio_sub` : `C(n-L, m-L) · n^L ≤ C(n,m) · m^L`, the integer form of
  the estimate `P(fixed L-set ⊆ random m-subset) ≤ (m/n)^L`;
* `DeltaDense.card_filter_superset` : the number of `m`-subsets of `[n]` containing a
  fixed `L`-set is `C(n-L, m-L)`;
* `DeltaDense.exists_card_eq_avoiding_family` : the general first-moment principle — if a
  family of `|I|` sets, each of size at least `L`, satisfies `|I|·m^L < n^L`, then some
  `m`-element subset of `[n]` contains none of them;
* `DeltaDense.pow_cond` : the analytic verification of `n^c·m^L < n^L` for `m = ⌈δn⌉`.
-/
import Mathlib

namespace DeltaDense

open Finset Pointwise

/-! ## Arithmetic progressions as finsets -/

/-- The arithmetic progression `{a, a+d, …, a+(L-1)d}`, as a `Finset ℕ`. -/
def apF (a d L : ℕ) : Finset ℕ := (range L).image (fun i => a + d * i)

lemma mem_apF {a d L x : ℕ} : x ∈ apF a d L ↔ ∃ i < L, a + d * i = x := by
  simp [apF]

/-- A progression with positive common difference has exactly `L` terms. -/
lemma card_apF (a : ℕ) {d : ℕ} (hd : 0 < d) (L : ℕ) : (apF a d L).card = L := by
  rw [apF, Finset.card_image_of_injective _ (by intro i j hij; simp at hij; omega),
    Finset.card_range]

lemma apF_mono (a d : ℕ) {L M : ℕ} (h : L ≤ M) : apF a d L ⊆ apF a d M :=
  Finset.image_subset_image (by simpa using h)

lemma self_mem_apF {a d L : ℕ} (hL : 0 < L) : a ∈ apF a d L :=
  mem_apF.2 ⟨0, hL, by ring⟩

lemma second_mem_apF {a d L : ℕ} (hL : 1 < L) : a + d ∈ apF a d L :=
  mem_apF.2 ⟨1, hL, by ring⟩

/-- The "L-shaped" subset of the two-dimensional grid `{t + i d₁ + j d₂ : i, j < k}`:
the first row together with the last column.  It has `2k - 1` elements. -/
def gridWitness (t d₁ d₂ k : ℕ) : Finset ℕ :=
  apF t d₁ k ∪ apF (t + d₁ * (k - 1)) d₂ k

/-- The L-shaped witness has at least `2k - 1` elements: the two progressions forming it
meet only at their common endpoint `t + (k-1)d₁`. -/
lemma card_gridWitness {t d₁ d₂ k : ℕ} (h1 : 0 < d₁) (h2 : 0 < d₂) (hk : 0 < k) :
    2 * k - 1 ≤ (gridWitness t d₁ d₂ k).card := by
  classical
  rw [gridWitness]
  set A := apF t d₁ k with hA
  set B := apF (t + d₁ * (k - 1)) d₂ k with hB
  have hinter : A ∩ B ⊆ {t + d₁ * (k - 1)} := by
    intro x hx
    rw [Finset.mem_inter] at hx
    obtain ⟨i, hi, hxi⟩ := mem_apF.1 hx.1
    obtain ⟨j, hj, hxj⟩ := mem_apF.1 hx.2
    have hle : d₁ * i ≤ d₁ * (k - 1) := Nat.mul_le_mul_left _ (by omega)
    have hj0 : j = 0 := by
      by_contra hj0
      have : 0 < d₂ * j := Nat.mul_pos h2 (Nat.pos_of_ne_zero hj0)
      omega
    rw [Finset.mem_singleton]
    omega
  have hcards : (A ∩ B).card ≤ 1 := le_trans (Finset.card_le_card hinter) (by simp)
  have hcA : A.card = k := card_apF _ h1 _
  have hcB : B.card = k := card_apF _ h2 _
  have hun := Finset.card_union_add_card_inter A B
  omega

/-- Any sumset of two `k`-term progressions (with arbitrary positive common differences)
contains the L-shaped witness of any smaller size `k₀ ≤ k`. -/
lemma gridWitness_subset_add {a b d₁ d₂ k₀ k : ℕ} (hk₀ : 0 < k₀) (hkk : k₀ ≤ k) :
    gridWitness (a + b) d₁ d₂ k₀ ⊆ apF a d₁ k + apF b d₂ k := by
  intro x hx
  rw [gridWitness, Finset.mem_union] at hx
  rcases hx with hx | hx
  · obtain ⟨i, hi, rfl⟩ := mem_apF.1 hx
    have he : a + b + d₁ * i = (a + d₁ * i) + (b + d₂ * 0) := by ring
    rw [he]
    exact Finset.add_mem_add (mem_apF.2 ⟨i, by omega, rfl⟩) (mem_apF.2 ⟨0, by omega, rfl⟩)
  · obtain ⟨j, hj, rfl⟩ := mem_apF.1 hx
    have he : a + b + d₁ * (k₀ - 1) + d₂ * j = (a + d₁ * (k₀ - 1)) + (b + d₂ * j) := by ring
    rw [he]
    exact Finset.add_mem_add (mem_apF.2 ⟨k₀ - 1, by omega, rfl⟩) (mem_apF.2 ⟨j, by omega, rfl⟩)

/-! ## The counting estimates -/

/-- The chance that a fixed `L`-element set lies inside a uniformly random `m`-element
subset of an `n`-element set is at most `(m/n)^L`.  Stated in subtraction-free integer
form: `C(n,m) · n^L ≤ C(n+L, m+L) · (m+L)^L`. -/
theorem choose_ratio (m n : ℕ) (hmn : m ≤ n) :
    ∀ L : ℕ, n.choose m * (n + L) ^ L ≤ (n + L).choose (m + L) * (m + L) ^ L := by
  intro L
  induction L with
  | zero => simp
  | succ L ih =>
    rcases Nat.eq_zero_or_pos (n + L) with h0 | hpos
    · have hn : n = 0 := by omega
      have hm : m = 0 := by omega
      subst hn; subst hm; simp
    · have key : (n + L + 1) * (n + L).choose (m + L)
          = (n + L + 1).choose (m + L + 1) * (m + L + 1) := Nat.add_one_mul_choose_eq _ _
      have hstep : (m + L) * (n + L + 1) ≤ (m + L + 1) * (n + L) := by nlinarith [hmn]
      have h1 : n.choose m * (n + L) ^ L * (n + L + 1) ^ L
          ≤ (n + L).choose (m + L) * (m + L) ^ L * (n + L + 1) ^ L :=
        Nat.mul_le_mul_right _ ih
      have h2 : ((m + L) * (n + L + 1)) ^ L ≤ ((m + L + 1) * (n + L)) ^ L :=
        Nat.pow_le_pow_left hstep L
      have h3 : n.choose m * (n + L + 1) ^ L * (n + L) ^ L
          ≤ (n + L).choose (m + L) * (m + L + 1) ^ L * (n + L) ^ L := by
        calc n.choose m * (n + L + 1) ^ L * (n + L) ^ L
            = n.choose m * (n + L) ^ L * (n + L + 1) ^ L := by ring
          _ ≤ (n + L).choose (m + L) * (m + L) ^ L * (n + L + 1) ^ L := h1
          _ = (n + L).choose (m + L) * ((m + L) * (n + L + 1)) ^ L := by rw [mul_pow]; ring
          _ ≤ (n + L).choose (m + L) * ((m + L + 1) * (n + L)) ^ L :=
              Nat.mul_le_mul_left _ h2
          _ = (n + L).choose (m + L) * (m + L + 1) ^ L * (n + L) ^ L := by rw [mul_pow]; ring
      have h4 : n.choose m * (n + L + 1) ^ L
          ≤ (n + L).choose (m + L) * (m + L + 1) ^ L :=
        Nat.le_of_mul_le_mul_right h3 (Nat.pow_pos hpos)
      calc n.choose m * (n + (L + 1)) ^ (L + 1)
          = (n + L + 1) * (n.choose m * (n + L + 1) ^ L) := by ring_nf
        _ ≤ (n + L + 1) * ((n + L).choose (m + L) * (m + L + 1) ^ L) :=
            Nat.mul_le_mul_left _ h4
        _ = ((n + L + 1) * (n + L).choose (m + L)) * (m + L + 1) ^ L := by ring
        _ = ((n + L + 1).choose (m + L + 1) * (m + L + 1)) * (m + L + 1) ^ L := by rw [key]
        _ = (n + (L + 1)).choose (m + (L + 1)) * (m + (L + 1)) ^ (L + 1) := by ring_nf

/-- Subtracted form of `choose_ratio`: `C(n-L, m-L) · n^L ≤ C(n,m) · m^L`. -/
theorem choose_ratio_sub {L m n : ℕ} (hLm : L ≤ m) (hmn : m ≤ n) :
    (n - L).choose (m - L) * n ^ L ≤ n.choose m * m ^ L := by
  have h := choose_ratio (m - L) (n - L) (by omega) L
  have e1 : n - L + L = n := by omega
  have e2 : m - L + L = m := by omega
  rwa [e1, e2] at h

/-- The number of `m`-element subsets of `[n]` containing a fixed subset `P` of `[n]` is
`C(n - |P|, m - |P|)`. -/
theorem card_filter_superset (n m : ℕ) {P : Finset ℕ} (hP : P ⊆ range n) (hPm : P.card ≤ m) :
    (((range n).powersetCard m).filter (fun S => P ⊆ S)).card
      = (n - P.card).choose (m - P.card) := by
  classical
  have hc := Finset.card_powersetCard (m - P.card) ((range n) \ P)
  rw [Finset.card_sdiff_of_subset hP, Finset.card_range] at hc
  rw [← hc]
  refine Finset.card_nbij' (fun S => S \ P) (fun U => U ∪ P) ?_ ?_ ?_ ?_
  · intro S hS
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_powersetCard] at hS
    simp only [Finset.mem_coe, Finset.mem_powersetCard]
    obtain ⟨⟨h1, h2⟩, h3⟩ := hS
    refine ⟨Finset.sdiff_subset_sdiff h1 (fun ⦃_⦄ h => h), ?_⟩
    rw [Finset.card_sdiff_of_subset h3, h2]
  · intro U hU
    simp only [Finset.mem_coe, Finset.mem_powersetCard] at hU
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_powersetCard]
    obtain ⟨h1, h2⟩ := hU
    have hdisj : Disjoint U P := by
      refine Finset.disjoint_left.2 fun a ha haP => ?_
      have := h1 ha
      simp only [Finset.mem_sdiff] at this
      exact this.2 haP
    refine ⟨⟨Finset.union_subset (h1.trans Finset.sdiff_subset) hP, ?_⟩,
      Finset.subset_union_right⟩
    rw [Finset.card_union_of_disjoint hdisj, h2]
    omega
  · intro S hS
    simp only [Finset.coe_filter, Set.mem_setOf_eq] at hS
    exact Finset.sdiff_union_of_subset hS.2
  · intro U hU
    simp only [Finset.mem_coe, Finset.mem_powersetCard] at hU
    have hdisj : Disjoint U P := by
      refine Finset.disjoint_left.2 fun a ha haP => ?_
      have := hU.1 ha
      simp only [Finset.mem_sdiff] at this
      exact this.2 haP
    exact Finset.union_sdiff_cancel_right hdisj

/-! ## The general first-moment principle -/

/-- **First-moment principle.**  Let `W : ι → Finset ℕ` be a family of sets indexed by a
finite set `I`, each of size at least `L ≥ 1`.  If `|I| · m^L < n^L` and `m ≤ n`, then
some `m`-element subset `S ⊆ [n]` contains none of the sets `W i`, `i ∈ I`.

This is the counting form of the probabilistic statement that a uniformly random
`m`-subset of `[n]` contains a fixed `L`-set with probability at most `(m/n)^L`. -/
theorem exists_card_eq_avoiding_family {ι : Type*} [DecidableEq ι] {n m L : ℕ}
    (I : Finset ι) (W : ι → Finset ℕ) (hW : ∀ i ∈ I, L ≤ (W i).card)
    (hmn : m ≤ n) (hL : 1 ≤ L) (hcond : I.card * m ^ L < n ^ L) :
    ∃ S ⊆ range n, S.card = m ∧ ∀ i ∈ I, ¬ (W i ⊆ S) := by
  classical
  have hn0 : 0 < n := by
    rcases Nat.eq_zero_or_pos n with rfl | h
    · exact absurd hcond (by rw [zero_pow (by omega : L ≠ 0)]; omega)
    · exact h
  obtain ⟨S₀, hS₀sub, hS₀card⟩ :=
    Finset.exists_subset_card_eq (by simpa using hmn : m ≤ (range n).card)
  by_cases hLm : L ≤ m
  · set Fam : Finset (Finset ℕ) := (range n).powersetCard m with hFam
    have hcardFam : Fam.card = n.choose m := by
      rw [hFam, Finset.card_powersetCard, Finset.card_range]
    set Bad : Finset (Finset ℕ) :=
      I.biUnion (fun i => Fam.filter (fun S => W i ⊆ S)) with hBad
    have hb1 : Bad.card ≤ I.card * ((n - L).choose (m - L)) := by
      refine le_trans (Finset.card_biUnion_le) ?_
      have hterm : ∀ i ∈ I,
          (Fam.filter (fun S => W i ⊆ S)).card ≤ (n - L).choose (m - L) := by
        intro i hi
        by_cases hsub : W i ⊆ range n
        · obtain ⟨P, hPW, hPcard⟩ := Finset.exists_subset_card_eq (hW i hi)
          have hmono : Fam.filter (fun S => W i ⊆ S) ⊆ Fam.filter (fun S => P ⊆ S) := by
            intro S hS
            rw [Finset.mem_filter] at hS ⊢
            exact ⟨hS.1, hPW.trans hS.2⟩
          refine le_trans (Finset.card_le_card hmono) ?_
          rw [hFam, card_filter_superset n m (hPW.trans hsub) (by omega), hPcard]
        · have he : (Fam.filter (fun S => W i ⊆ S)) = ∅ := by
            rw [Finset.filter_eq_empty_iff]
            intro S hS hsubS
            rw [hFam, Finset.mem_powersetCard] at hS
            exact hsub (hsubS.trans hS.1)
          simp [he]
      refine le_trans (Finset.sum_le_sum hterm) ?_
      rw [Finset.sum_const, smul_eq_mul]
    have hchoose_pos : 0 < n.choose m := Nat.choose_pos hmn
    have hb2 : I.card * ((n - L).choose (m - L)) < n.choose m := by
      have h1 := choose_ratio_sub hLm hmn
      have h2 : I.card * ((n - L).choose (m - L)) * n ^ L
          ≤ I.card * (n.choose m * m ^ L) := by
        calc I.card * ((n - L).choose (m - L)) * n ^ L
            = I.card * ((n - L).choose (m - L) * n ^ L) := by ring
          _ ≤ I.card * (n.choose m * m ^ L) := Nat.mul_le_mul_left _ h1
      have h3 : I.card * (n.choose m * m ^ L) < n.choose m * n ^ L := by
        calc I.card * (n.choose m * m ^ L) = n.choose m * (I.card * m ^ L) := by ring
          _ < n.choose m * n ^ L := mul_lt_mul_of_pos_left hcond hchoose_pos
      exact Nat.lt_of_mul_lt_mul_right (lt_of_le_of_lt h2 h3)
    have hne : (Fam \ Bad).Nonempty := by
      rw [← Finset.card_pos]
      have h1 := Finset.card_sdiff_add_card_inter Fam Bad
      have h2 : (Fam ∩ Bad).card ≤ Bad.card := Finset.card_le_card Finset.inter_subset_right
      omega
    obtain ⟨S, hS⟩ := hne
    rw [Finset.mem_sdiff] at hS
    obtain ⟨hSmem, hSbad⟩ := hS
    have hSmem' : S ⊆ range n ∧ S.card = m := by
      rw [hFam, Finset.mem_powersetCard] at hSmem; exact hSmem
    refine ⟨S, hSmem'.1, hSmem'.2, ?_⟩
    intro i hi hsubS
    exact hSbad (Finset.mem_biUnion.2 ⟨i, hi, Finset.mem_filter.2 ⟨hSmem, hsubS⟩⟩)
  · refine ⟨S₀, hS₀sub, hS₀card, ?_⟩
    intro i hi hsubS
    have h1 := Finset.card_le_card hsubS
    have h2 := hW i hi
    omega

/-! ## Progression-free and grid-free dense sets, in integer form -/

/-- If `m ≤ n`, `2 ≤ L` and `n² · m^L < n^L`, then there is a set `S ⊆ [n]` with exactly
`m` elements which contains no `L`-term arithmetic progression with positive common
difference.  (There are at most `n²` such progressions inside `[n]`.) -/
theorem exists_card_eq_no_ap {n m L : ℕ} (hmn : m ≤ n) (hL : 2 ≤ L)
    (hcond : n ^ 2 * m ^ L < n ^ L) :
    ∃ S ⊆ range n, S.card = m ∧ ∀ a d : ℕ, 0 < d → ¬ (apF a d L ⊆ S) := by
  classical
  set I : Finset (ℕ × ℕ) := (range n) ×ˢ (Icc 1 n) with hI
  have hIcard : I.card = n ^ 2 := by
    rw [hI, Finset.card_product, Finset.card_range, Nat.card_Icc]
    simp [sq]
  obtain ⟨S, hSsub, hScard, hSno⟩ :=
    exists_card_eq_avoiding_family I (fun p => apF p.1 p.2 L)
      (fun p hp => by
        rw [hI, Finset.mem_product, Finset.mem_Icc] at hp
        rw [card_apF _ (by omega : 0 < p.2)])
      hmn (by omega) (by rw [hIcard]; exact hcond)
  refine ⟨S, hSsub, hScard, ?_⟩
  intro a d hd hsub
  have ha : a < n := by simpa using hSsub (hsub (self_mem_apF (by omega)))
  have had : a + d < n := by simpa using hSsub (hsub (second_mem_apF (by omega)))
  exact hSno (a, d) (by rw [hI, Finset.mem_product, Finset.mem_Icc]; exact ⟨by simpa using ha,
    hd, by omega⟩) hsub

/-- If `m ≤ n`, `2 ≤ k` and `n³ · m^(2k-1) < n^(2k-1)`, then there is a set `S ⊆ [n]` with
exactly `m` elements which contains no L-shaped grid witness `gridWitness t d₁ d₂ k`.
(There are at most `n³` such witnesses inside `[n]`, and each has `2k-1` elements.) -/
theorem exists_card_eq_no_grid {n m k : ℕ} (hmn : m ≤ n) (hk : 2 ≤ k)
    (hcond : n ^ 3 * m ^ (2 * k - 1) < n ^ (2 * k - 1)) :
    ∃ S ⊆ range n, S.card = m ∧
      ∀ t d₁ d₂ : ℕ, 0 < d₁ → 0 < d₂ → ¬ (gridWitness t d₁ d₂ k ⊆ S) := by
  classical
  set I : Finset ((ℕ × ℕ) × ℕ) := ((range n) ×ˢ (Icc 1 n)) ×ˢ (Icc 1 n) with hI
  have hIcard : I.card = n ^ 3 := by
    rw [hI, Finset.card_product, Finset.card_product, Finset.card_range, Nat.card_Icc]
    simp only [Nat.add_sub_cancel]
    ring
  obtain ⟨S, hSsub, hScard, hSno⟩ :=
    exists_card_eq_avoiding_family I (fun q => gridWitness q.1.1 q.1.2 q.2 k)
      (fun q hq => by
        rw [hI, Finset.mem_product, Finset.mem_product, Finset.mem_Icc, Finset.mem_Icc] at hq
        exact card_gridWitness (by omega) (by omega) (by omega))
      hmn (by omega) (by rw [hIcard]; exact hcond)
  refine ⟨S, hSsub, hScard, ?_⟩
  intro t d₁ d₂ h1 h2 hsub
  have hmem1 : t ∈ gridWitness t d₁ d₂ k :=
    Finset.mem_union_left _ (self_mem_apF (by omega))
  have hmem2 : t + d₁ ∈ gridWitness t d₁ d₂ k :=
    Finset.mem_union_left _ (second_mem_apF (by omega))
  have hmem3 : t + d₁ * (k - 1) + d₂ ∈ gridWitness t d₁ d₂ k :=
    Finset.mem_union_right _ (second_mem_apF (by omega))
  have ht : t < n := by simpa using hSsub (hsub hmem1)
  have htd : t + d₁ < n := by simpa using hSsub (hsub hmem2)
  have htd2 : t + d₁ * (k - 1) + d₂ < n := by simpa using hSsub (hsub hmem3)
  refine hSno ((t, d₁), d₂) ?_ hsub
  rw [hI, Finset.mem_product, Finset.mem_product, Finset.mem_Icc, Finset.mem_Icc,
    Finset.mem_range]
  dsimp only
  exact ⟨⟨ht, h1, by omega⟩, h2, by omega⟩

/-! ## The analytic form of the counting condition -/

/-- With `m = ⌈δ n⌉` the first-moment condition `n^c · m^L < n^L` holds as soon as
`L ≥ (c + 1/2)·log n / log (1/δ)` and `n` is large enough that `δ n log(1/δ) ≥ 100`. -/
theorem pow_cond (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) (n : ℕ) (hn2 : 2 ≤ n)
    (hδn : 1 ≤ δ * n) (hbig : 100 ≤ δ * n * Real.log (1 / δ)) (c : ℕ) (hc : c ≤ 10)
    (L : ℕ) (hL : ((c : ℝ) + 1 / 2) * (Real.log n / Real.log (1 / δ)) ≤ L) :
    n ^ c * (⌈δ * (n : ℝ)⌉₊) ^ L < n ^ L := by
  set l : ℝ := Real.log (1 / δ) with hl
  have hlpos : 0 < l := by
    rw [hl]; simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  have hn0 : (0 : ℝ) < n := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn2
    linarith
  have hlogn : 0 < Real.log n := Real.log_pos (by exact_mod_cast hn2)
  have hcR : (c : ℝ) ≤ 10 := by exact_mod_cast hc
  set m : ℕ := ⌈δ * (n : ℝ)⌉₊ with hm
  have hm1 : 1 ≤ m := by
    rw [hm]; exact Nat.one_le_ceil_iff.2 (by linarith)
  have hmR : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm1
  have hmlt : (m : ℝ) < δ * n + 1 := Nat.ceil_lt_add_one (by positivity)
  have hlogm : Real.log m ≤ Real.log n - (99 / 100) * l := by
    have step1 : Real.log m ≤ Real.log (δ * n + 1) :=
      Real.log_le_log (by linarith) (le_of_lt hmlt)
    have hfac : δ * (n : ℝ) + 1 = (δ * n) * (1 + 1 / (δ * n)) := by field_simp
    have step2 : Real.log (δ * n + 1) = Real.log (δ * n) + Real.log (1 + 1 / (δ * n)) := by
      rw [hfac, Real.log_mul (by positivity) (by positivity)]
    have step3 : Real.log (1 + 1 / (δ * n)) ≤ 1 / (δ * n) := by
      have := Real.log_le_sub_one_of_pos (x := 1 + 1 / (δ * n)) (by positivity)
      linarith
    have step4 : Real.log (δ * n) = Real.log n - l := by
      rw [Real.log_mul (ne_of_gt h0) (ne_of_gt hn0), hl]
      simp only [one_div, Real.log_inv]
      ring
    have step5 : 1 / (δ * (n : ℝ)) ≤ l / 100 := by
      rw [div_le_div_iff₀ (by positivity) (by norm_num)]
      nlinarith [hbig]
    linarith
  have hkey : (c : ℝ) * Real.log n + (L : ℝ) * Real.log m < (L : ℝ) * Real.log n := by
    have hLpos : (0 : ℝ) ≤ (L : ℝ) := Nat.cast_nonneg _
    have h6 : (L : ℝ) * Real.log m ≤ (L : ℝ) * (Real.log n - (99 / 100) * l) :=
      mul_le_mul_of_nonneg_left hlogm hLpos
    have h7 : ((c : ℝ) + 1 / 2) * Real.log n ≤ (L : ℝ) * l := by
      refine (div_le_iff₀ hlpos).1 ?_
      calc ((c : ℝ) + 1 / 2) * Real.log n / l
          = ((c : ℝ) + 1 / 2) * (Real.log n / l) := by ring
        _ ≤ (L : ℝ) := hL
    nlinarith [h6, h7, hlogn, hcR]
  have hreal : (n : ℝ) ^ c * (m : ℝ) ^ L < (n : ℝ) ^ L := by
    have hx : (0 : ℝ) < (n : ℝ) ^ c * (m : ℝ) ^ L := by positivity
    have hy : (0 : ℝ) < (n : ℝ) ^ L := by positivity
    rw [← Real.log_lt_log_iff hx hy,
      Real.log_mul (by positivity) (by positivity), Real.log_pow, Real.log_pow, Real.log_pow]
    linarith [hkey]
  exact_mod_cast hreal

/-! ## Dense sets with no long progressions and no progression sumsets -/

/-- For `0 < δ < 1` and `n` large (`δ n log(1/δ) ≥ 100` suffices) there is a set
`S ⊆ [n]` of size at least `δ n` containing no arithmetic progression of length
`(5/2)·log n / log (1/δ)` or more. -/
theorem exists_dense_no_ap (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) {n : ℕ} (hn2 : 2 ≤ n)
    (hδn : 1 ≤ δ * n) (hbig : 100 ≤ δ * n * Real.log (1 / δ)) :
    ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ L : ℕ, (5 / 2) * (Real.log n / Real.log (1 / δ)) ≤ L →
        ∀ a d : ℕ, 0 < d → ¬ (apF a d L ⊆ S) := by
  have hlpos : 0 < Real.log (1 / δ) := by
    simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  have hn0 : (0 : ℝ) < n := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn2
    linarith
  have hR1 : 1 ≤ Real.log n / Real.log (1 / δ) := by
    have hle : 1 / δ ≤ (n : ℝ) := by
      rw [div_le_iff₀ h0]; linarith [hδn]
    have := Real.log_le_log (by positivity) hle
    rw [le_div_iff₀ hlpos]
    linarith
  set L₀ : ℕ := ⌈(5 / 2) * (Real.log n / Real.log (1 / δ))⌉₊ with hL₀
  have hL₀ge : (5 / 2) * (Real.log n / Real.log (1 / δ)) ≤ L₀ := Nat.le_ceil _
  have h2L : 2 ≤ L₀ := by
    have : (2 : ℝ) ≤ (L₀ : ℝ) := by linarith
    exact_mod_cast this
  have hmn : ⌈δ * (n : ℝ)⌉₊ ≤ n := Nat.ceil_le.2 (by nlinarith)
  have hcond : n ^ 2 * (⌈δ * (n : ℝ)⌉₊) ^ L₀ < n ^ L₀ := by
    refine pow_cond δ h0 h1 n hn2 hδn hbig 2 (by norm_num) L₀ ?_
    push_cast
    linarith
  obtain ⟨S, hSsub, hScard, hSno⟩ := exists_card_eq_no_ap hmn h2L hcond
  refine ⟨S, hSsub, ?_, ?_⟩
  · rw [hScard]; exact Nat.le_ceil _
  · intro L hLge a d hd hsub
    exact hSno a d hd ((apF_mono a d (Nat.ceil_le.2 hLge)).trans hsub)

/-- If `a ∈ A` then `A + B` contains the translate `a + B`; for `B` a progression this
says `A + B` contains a progression of the same length. -/
lemma apF_subset_add_of_mem {A : Finset ℕ} {a b d L : ℕ} (ha : a ∈ A) :
    apF (a + b) d L ⊆ A + apF b d L := by
  intro x hx
  obtain ⟨i, hi, rfl⟩ := mem_apF.1 hx
  have he : a + b + d * i = a + (b + d * i) := by ring
  rw [he]
  exact Finset.add_mem_add ha (mem_apF.2 ⟨i, hi, rfl⟩)

/-- **Arbitrary first summand.**  For `0 < δ < 1` and `n` large there is `S ⊆ [n]` with
`|S| ≥ δ n` such that for *every* nonempty finite set `A` and every arithmetic
progression `B` of length at least `(5/2)·log n / log (1/δ)`, the sumset `A + B` is not
contained in `S`.  (Here no assumption whatsoever is made on `A`: a single translate
`a + B ⊆ S` already violates progression-freeness of `S`.) -/
theorem exists_dense_no_sumset_with_ap (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) {n : ℕ}
    (hn2 : 2 ≤ n) (hδn : 1 ≤ δ * n) (hbig : 100 ≤ δ * n * Real.log (1 / δ)) :
    ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ (A : Finset ℕ) (b d L : ℕ), A.Nonempty → 0 < d →
        (5 / 2) * (Real.log n / Real.log (1 / δ)) ≤ L → ¬ (A + apF b d L ⊆ S) := by
  obtain ⟨S, hSsub, hScard, hSno⟩ := exists_dense_no_ap δ h0 h1 hn2 hδn hbig
  refine ⟨S, hSsub, hScard, ?_⟩
  intro A b d L hA hd hL hsub
  obtain ⟨a, ha⟩ := hA
  exact hSno L hL (a + b) d hd ((apF_subset_add_of_mem ha).trans hsub)

/-- **Main theorem (sharpness with `C(δ) = 3`).**  For every `0 < δ < 1` and every
sufficiently large `n` (it suffices that `δ² n ≥ 1` and `δ n log (1/δ) ≥ 100`) there is a
set `S ⊆ [n]` with `|S| ≥ δ n` such that for *all* pairs of arithmetic progressions
`A = {a, a+d₁, …}` and `B = {b, b+d₂, …}` with arbitrary positive common differences
`d₁, d₂` and common length `k ≥ 3 log n / log (1/δ)`, the sumset `A + B` is **not**
contained in `S`.

Progressions are the extremal shape for this problem: `A + B` is then a two-dimensional
grid, containing an L-shaped configuration of `2k-1` points described by only three
parameters `(t, d₁, d₂)`, whence the union bound of size `n³` and the constant `3`. -/
theorem exists_dense_avoiding_ap_sumsets (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) {n : ℕ}
    (hn2 : 2 ≤ n) (hδn : 1 ≤ δ ^ 2 * n) (hbig : 100 ≤ δ * n * Real.log (1 / δ)) :
    ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ a b d₁ d₂ k : ℕ, 0 < d₁ → 0 < d₂ →
        3 * (Real.log n / Real.log (1 / δ)) ≤ k →
        ¬ (apF a d₁ k + apF b d₂ k ⊆ S) := by
  have hlpos : 0 < Real.log (1 / δ) := by
    simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  have hn0 : (0 : ℝ) < n := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn2
    linarith
  have hδn1 : 1 ≤ δ * n := by nlinarith [hδn, h0, h1, hn0]
  -- `n ≥ (1/δ)²`, hence `log n ≥ 2 log (1/δ)`
  have hR2 : 2 ≤ Real.log n / Real.log (1 / δ) := by
    have hle : (1 / δ) ^ 2 ≤ (n : ℝ) := by
      rw [div_pow, one_pow, div_le_iff₀ (by positivity)]
      linarith [hδn]
    have hlog := Real.log_le_log (by positivity) hle
    rw [Real.log_pow] at hlog
    rw [le_div_iff₀ hlpos]
    push_cast at hlog
    linarith
  set R : ℝ := Real.log n / Real.log (1 / δ) with hR
  set k₀ : ℕ := ⌈(7 / 4) * R⌉₊ + 1 with hk₀
  have hk₀ge : (7 / 4) * R + 1 ≤ (k₀ : ℝ) := by
    rw [hk₀]; push_cast; linarith [Nat.le_ceil ((7 / 4) * R)]
  have hk₀le : (k₀ : ℝ) ≤ (7 / 4) * R + 2 := by
    rw [hk₀]; push_cast
    have := Nat.ceil_lt_add_one (a := (7 / 4) * R) (by positivity)
    linarith
  have hk₀2 : 2 ≤ k₀ := by
    have : (2 : ℝ) ≤ (k₀ : ℝ) := by linarith
    exact_mod_cast this
  have hcast : ((2 * k₀ - 1 : ℕ) : ℝ) = 2 * (k₀ : ℝ) - 1 := by
    have hle : 1 ≤ 2 * k₀ := by omega
    push_cast [Nat.cast_sub hle]
    ring
  have hmn : ⌈δ * (n : ℝ)⌉₊ ≤ n := Nat.ceil_le.2 (by nlinarith)
  have hcond : n ^ 3 * (⌈δ * (n : ℝ)⌉₊) ^ (2 * k₀ - 1) < n ^ (2 * k₀ - 1) := by
    refine pow_cond δ h0 h1 n hn2 hδn1 hbig 3 (by norm_num) (2 * k₀ - 1) ?_
    rw [hcast]
    push_cast
    linarith
  obtain ⟨S, hSsub, hScard, hSno⟩ := exists_card_eq_no_grid hmn hk₀2 hcond
  refine ⟨S, hSsub, by rw [hScard]; exact Nat.le_ceil _, ?_⟩
  intro a b d₁ d₂ k hd₁ hd₂ hk hsub
  have hkR : (k₀ : ℝ) ≤ (k : ℝ) := by linarith
  have hkk : k₀ ≤ k := by exact_mod_cast hkR
  exact hSno (a + b) d₁ d₂ hd₁ hd₂
    ((gridWitness_subset_add (by omega) hkk).trans hsub)

/-- Asymptotic packaging of `exists_dense_avoiding_ap_sumsets`: for every `0 < δ < 1`, for
all sufficiently large `n`, there is a `δ`-dense subset of `[n]` containing no sumset of
two arithmetic progressions of common length at least `3 log n / log (1/δ)`. -/
theorem eventually_exists_dense_avoiding_ap_sumsets (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) :
    ∀ᶠ n : ℕ in Filter.atTop, ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ a b d₁ d₂ k : ℕ, 0 < d₁ → 0 < d₂ →
        3 * (Real.log n / Real.log (1 / δ)) ≤ k →
        ¬ (apF a d₁ k + apF b d₂ k ⊆ S) := by
  have hlpos : 0 < Real.log (1 / δ) := by
    simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  rw [Filter.eventually_atTop]
  refine ⟨max 2 (max ⌈1 / δ ^ 2⌉₊ ⌈100 / (δ * Real.log (1 / δ))⌉₊), fun n hn => ?_⟩
  have hn2 : 2 ≤ n := le_trans (le_max_left _ _) hn
  have hA : ⌈1 / δ ^ 2⌉₊ ≤ n := le_trans (le_trans (le_max_left _ _) (le_max_right 2 _)) hn
  have hB : ⌈100 / (δ * Real.log (1 / δ))⌉₊ ≤ n :=
    le_trans (le_trans (le_max_right _ _) (le_max_right 2 _)) hn
  have hδn : 1 ≤ δ ^ 2 * n := by
    have h1n : 1 / δ ^ 2 ≤ (n : ℝ) := le_trans (Nat.le_ceil _) (by exact_mod_cast hA)
    rw [div_le_iff₀ (by positivity)] at h1n
    linarith
  have hbig : 100 ≤ δ * n * Real.log (1 / δ) := by
    have h2n : 100 / (δ * Real.log (1 / δ)) ≤ (n : ℝ) :=
      le_trans (Nat.le_ceil _) (by exact_mod_cast hB)
    rw [div_le_iff₀ (by positivity)] at h2n
    nlinarith [h2n]
  exact exists_dense_avoiding_ap_sumsets δ h0 h1 hn2 hδn hbig

end DeltaDense