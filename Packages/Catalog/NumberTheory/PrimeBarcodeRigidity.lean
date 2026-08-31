/-
# Rigidity of the prime barcode: the inverse problem, window counts and even-scale jumps

Cycle 2 of the research thread.  `PrimeBarcodeInvariants.lean` computed the Betti staircase
`b₀(ε, n) = 1 + #{i < n : gap_i > ε}` of the prime point cloud, and
`PrimeBarcodeArithmetic.lean` showed that the bar-length spectrum is atomic (all bars even
after the first), refuting the conjectured exponential law.  Three questions were left
open by that analysis, and are answered here.

1. *Inverse problem.*  Does the Betti curve remember the whole barcode, or only some
   coarse statistics?  Answer: it remembers **everything** — the Betti curve is a complete
   invariant of the `H₀` barcode (`PrimeRigid.betti_determines_barcode`).

2. *Window counts.*  Can individual bar lengths be read off from the Betti curve?  Answer:
   yes, as a discrete derivative (`PrimeRigid.bettiZero_window`), and in particular the
   twin prime counting function is the single Betti difference
   `b₀(1, n) - b₀(2, n)` (`PrimeRigid.twinIndexCount_eq_betti_difference`).

3. *Rigidity of the staircase.*  Because the prime bar lengths lie in `{1} ∪ 2ℕ`, the prime
   Betti curve is constant between consecutive even integers
   (`PrimeRigid.prime_bettiZero_const_on_even_window`): the prime barcode can only jump at
   even scales (and once, at scale `1`).

Finally we run the telescoping identity backwards: the atomicity of the barcode forces the
total persistence to grow at least linearly, which is exactly the elementary prime bound
`p_n ≥ 2n + 1` (`PrimeRigid.two_mul_add_one_le_nth_prime`,
`PrimeRigid.totalPersistence_lower_bound`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  H4: the Betti curve `ε ↦ b₀(ε, n)` determines the barcode
multiset (no information is lost by passing to the staircase).  H5: the twin prime counting
function is a *single difference* of Betti numbers, not merely an asymptotic defect.
H6: the prime staircase jumps only at even scales.

Experiment (Experimenter).  H4 was reduced to a statement about finite multisets of reals:
if two multisets have the same upper-tail counting function then they are equal.  The proof
peels off the maximum: a common lower bound shows the cardinalities agree; evaluating the
counting function at the larger maximum forces the two maxima to coincide; the cons
decomposition `A = a ::ₘ A'` transports the hypothesis to the smaller multisets, and the
induction closes.  H5 and H6 follow from the parity theorem of the previous cycle.

Analysis (Analyst).  The three results explain *why* the previous cycle's refutation is
structural rather than accidental: the Betti curve of a line cloud is a lossless encoding
of the gap multiset, so any statistical law proposed for the barcode is a law for the gaps
themselves — and the gaps live on a lattice.  Running the telescoping identity backwards
turns the lattice structure into the arithmetic inequality `p_n ≥ 2n + 1`, closing the loop
between topology and arithmetic.

Critique (Critic).  The inverse-problem theorem quantifies over *all* real scales, so it is
not a finite check; it is proved by induction on the cardinality, not by `decide`.  The
window and rigidity statements are stated with strict/non-strict inequalities chosen so
that no boundary case is hidden: `prime_bettiZero_const_on_even_window` explicitly excludes
`k = 0`, where the length-`1` bar does cause a jump.

Synthesis (PI).  The prime barcode is rigid: it is determined by its Betti curve, its
jumps sit on the even lattice, its scale-`2` jump counts twin primes, and its aggregate is
the prime counting inequality `p_n ≥ 2n + 1`.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Catalog.Novelty.PrimeBarcodeInvariants
import Catalog.NumberTheory.PrimeBarcodeArithmetic

namespace PrimeRigid

open Finset
open scoped Classical

/-! ### The barcode multiset and the inverse problem -/

/-- The `H₀` barcode of the first `n + 1` points of a line cloud, as the multiset of the
`n` finite bar lengths. -/
noncomputable def barcodeMultiset (p : ℕ → ℝ) (n : ℕ) : Multiset ℝ :=
  (Multiset.range n).map (fun i => p (i + 1) - p i)

/-- A finite multiset of reals has a strict lower bound. -/
theorem exists_lt_all (A : Multiset ℝ) : ∃ ε : ℝ, ∀ x ∈ A, ε < x := by
  induction A using Multiset.induction with
  | empty => exact ⟨0, by simp⟩
  | cons a s ih =>
      obtain ⟨ε, hε⟩ := ih
      refine ⟨min ε (a - 1), ?_⟩
      intro x hx
      rcases Multiset.mem_cons.mp hx with rfl | hx
      · have : min ε (x - 1) ≤ x - 1 := min_le_right _ _
        linarith
      · have h1 : min ε (a - 1) ≤ ε := min_le_left _ _
        exact lt_of_le_of_lt h1 (hε x hx)

/-- **The upper-tail counting function determines a finite multiset of reals.**  This is the
multiset form of the statement that a barcode is determined by its Betti curve. -/
theorem multiset_eq_of_tail_counts_eq :
    ∀ (N : ℕ) (A B : Multiset ℝ), A.card ≤ N →
      (∀ ε : ℝ, (A.filter (fun x => ε < x)).card = (B.filter (fun x => ε < x)).card) →
      A = B := by
  intro N
  induction N with
  | zero =>
      intro A B hA h
      have hA0 : A = 0 := Multiset.card_eq_zero.mp (Nat.le_zero.mp hA)
      subst hA0
      obtain ⟨ε, hε⟩ := exists_lt_all B
      have hcount := h ε
      simp only [Multiset.filter_zero, Multiset.card_zero] at hcount
      have hfil : B.filter (fun x => ε < x) = B := by
        rw [Multiset.filter_eq_self]
        exact fun x hx => hε x hx
      rw [hfil] at hcount
      exact (Multiset.card_eq_zero.mp hcount.symm).symm
  | succ N ih =>
      intro A B hA h
      rcases Multiset.empty_or_exists_mem A with rfl | ⟨a₀, ha₀⟩
      · obtain ⟨ε, hε⟩ := exists_lt_all B
        have hcount := h ε
        simp only [Multiset.filter_zero, Multiset.card_zero] at hcount
        have hfil : B.filter (fun x => ε < x) = B := by
          rw [Multiset.filter_eq_self]
          exact fun x hx => hε x hx
        rw [hfil] at hcount
        exact (Multiset.card_eq_zero.mp hcount.symm).symm
      -- both multisets are nonempty, with the same maximum
      have hBne : B ≠ 0 := by
        intro hB
        obtain ⟨ε, hε⟩ := exists_lt_all A
        have hcount := h ε
        rw [hB] at hcount
        have hfil : A.filter (fun x => ε < x) = A := by
          rw [Multiset.filter_eq_self]
          exact fun x hx => hε x hx
        rw [hfil] at hcount
        simp only [Multiset.filter_zero, Multiset.card_zero] at hcount
        exact absurd (Multiset.card_eq_zero.mp hcount) (by
          intro hA0; rw [hA0] at ha₀; exact absurd ha₀ (by simp))
      obtain ⟨b₀, hb₀⟩ := Multiset.exists_mem_of_ne_zero hBne
      -- maxima, via the underlying finite sets
      have hAfin : A.toFinset.Nonempty := ⟨a₀, Multiset.mem_toFinset.mpr ha₀⟩
      have hBfin : B.toFinset.Nonempty := ⟨b₀, Multiset.mem_toFinset.mpr hb₀⟩
      set a := A.toFinset.max' hAfin with hadef
      set b := B.toFinset.max' hBfin with hbdef
      have hamem : a ∈ A := Multiset.mem_toFinset.mp (A.toFinset.max'_mem hAfin)
      have hbmem : b ∈ B := Multiset.mem_toFinset.mp (B.toFinset.max'_mem hBfin)
      have hAle : ∀ x ∈ A, x ≤ a := fun x hx =>
        Finset.le_max' _ x (Multiset.mem_toFinset.mpr hx)
      have hBle : ∀ x ∈ B, x ≤ b := fun x hx =>
        Finset.le_max' _ x (Multiset.mem_toFinset.mpr hx)
      have hab : a = b := by
        by_contra hne
        rcases lt_or_gt_of_ne hne with hlt | hlt
        · -- some element of `B` exceeds `a`, none of `A` does
          have h1 : A.filter (fun x => a < x) = 0 := by
            rw [Multiset.filter_eq_nil]
            exact fun x hx => not_lt.mpr (hAle x hx)
          have h2 : b ∈ B.filter (fun x => a < x) :=
            Multiset.mem_filter.mpr ⟨hbmem, hlt⟩
          have := h a
          rw [h1] at this
          simp only [Multiset.card_zero] at this
          have : B.filter (fun x => a < x) = 0 := Multiset.card_eq_zero.mp this.symm
          rw [this] at h2
          exact absurd h2 (by simp)
        · have h1 : B.filter (fun x => b < x) = 0 := by
            rw [Multiset.filter_eq_nil]
            exact fun x hx => not_lt.mpr (hBle x hx)
          have h2 : a ∈ A.filter (fun x => b < x) :=
            Multiset.mem_filter.mpr ⟨hamem, hlt⟩
          have := h b
          rw [h1] at this
          simp only [Multiset.card_zero] at this
          have : A.filter (fun x => b < x) = 0 := Multiset.card_eq_zero.mp this
          rw [this] at h2
          exact absurd h2 (by simp)
      -- peel off the common maximum
      obtain ⟨A', hA'⟩ : ∃ A', A = a ::ₘ A' := ⟨A.erase a, (Multiset.cons_erase hamem).symm⟩
      obtain ⟨B', hB'⟩ : ∃ B', B = b ::ₘ B' := ⟨B.erase b, (Multiset.cons_erase hbmem).symm⟩
      have hcard : A'.card ≤ N := by
        have : A.card = A'.card + 1 := by rw [hA']; simp
        omega
      have hstep : ∀ ε : ℝ,
          (A'.filter (fun x => ε < x)).card = (B'.filter (fun x => ε < x)).card := by
        intro ε
        have hA1 := h ε
        rw [hA', hB', ← hab] at hA1
        by_cases hεa : ε < a
        · rw [Multiset.filter_cons_of_pos _ hεa, Multiset.filter_cons_of_pos _ hεa] at hA1
          simpa using hA1
        · rw [Multiset.filter_cons_of_neg _ hεa, Multiset.filter_cons_of_neg _ hεa] at hA1
          exact hA1
      have := ih A' B' hcard hstep
      rw [hA', hB', ← hab, this]

/-- The Betti curve of a line cloud is `1` plus the upper-tail counting function of its
barcode multiset. -/
theorem bettiZero_eq_one_add_tail (p : ℕ → ℝ) (ε : ℝ) (n : ℕ) :
    PrimeBarcode.bettiZero p ε n
      = 1 + ((barcodeMultiset p n).filter (fun x => ε < x)).card := by
  classical
  rw [PrimeBarcode.bettiZero_eq]
  congr 1
  unfold barcodeMultiset
  rw [Multiset.filter_map, Multiset.card_map]
  rfl

/-- **The Betti curve is a complete invariant of the `H₀` barcode.**  Two point clouds on a
line whose Betti curves agree at every scale have the same barcode, and conversely.  In
particular no information about the prime gaps is lost in passing to the Betti staircase. -/
theorem betti_determines_barcode (p q : ℕ → ℝ) (n : ℕ) :
    (∀ ε : ℝ, PrimeBarcode.bettiZero p ε n = PrimeBarcode.bettiZero q ε n) ↔
      barcodeMultiset p n = barcodeMultiset q n := by
  classical
  constructor
  · intro h
    refine multiset_eq_of_tail_counts_eq (barcodeMultiset p n).card _ _ le_rfl ?_
    intro ε
    have h1 := bettiZero_eq_one_add_tail p ε n
    have h2 := bettiZero_eq_one_add_tail q ε n
    have h3 := h ε
    omega
  · intro h ε
    rw [bettiZero_eq_one_add_tail, bettiZero_eq_one_add_tail, h]

/-! ### Window counts: reading bar lengths off the Betti curve -/

/-- **The Betti curve is the cumulative bar-length histogram.**  The difference of Betti
numbers at two scales counts exactly the bars whose length lies in the window. -/
theorem bettiZero_window (p : ℕ → ℝ) (n : ℕ) {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    PrimeBarcode.bettiZero p ε₁ n - PrimeBarcode.bettiZero p ε₂ n
      = ((Finset.range n).filter
          (fun i => ε₁ < p (i + 1) - p i ∧ p (i + 1) - p i ≤ ε₂)).card := by
  classical
  rw [PrimeBarcode.bettiZero_eq, PrimeBarcode.bettiZero_eq]
  have hsplit :
      ((Finset.range n).filter (fun i => ε₁ < p (i + 1) - p i)).card
        = ((Finset.range n).filter (fun i => ε₂ < p (i + 1) - p i)).card
          + ((Finset.range n).filter
              (fun i => ε₁ < p (i + 1) - p i ∧ p (i + 1) - p i ≤ ε₂)).card := by
    rw [← Finset.card_union_of_disjoint]
    · congr 1
      ext i
      simp only [Finset.mem_filter, Finset.mem_union, Finset.mem_range]
      constructor
      · rintro ⟨hi, h1⟩
        by_cases h2 : ε₂ < p (i + 1) - p i
        · exact Or.inl ⟨hi, h2⟩
        · exact Or.inr ⟨hi, h1, not_lt.mp h2⟩
      · rintro (⟨hi, h2⟩ | ⟨hi, h1, -⟩)
        · exact ⟨hi, lt_of_le_of_lt h h2⟩
        · exact ⟨hi, h1⟩
    · rw [Finset.disjoint_left]
      rintro i hi hi'
      have h1 := (Finset.mem_filter.mp hi).2
      have h2 := (Finset.mem_filter.mp hi').2
      linarith [h2.2]
  omega

/-- **The twin prime counting function is a single Betti difference.**  For every `n`,
`b₀(1, n) - b₀(2, n)` is exactly the number of twin-prime bars among the first `n` bars. -/
theorem twinIndexCount_eq_betti_difference (n : ℕ) :
    PrimeBarcode.bettiZero PrimePH.P 1 n - PrimeBarcode.bettiZero PrimePH.P 2 n
      = PrimeBarcodeArith.twinIndexCount n := by
  classical
  rw [bettiZero_window PrimePH.P n (by norm_num : (1 : ℝ) ≤ 2)]
  unfold PrimeBarcodeArith.twinIndexCount
  congr 1
  apply Finset.filter_congr
  intro i _
  rw [PrimePH.death_scale_eq_primeGap i]
  constructor
  · rintro ⟨h1, h2⟩
    have h1' : 1 < TwinPrimeGaps.primeGap i := by exact_mod_cast h1
    have h2' : TwinPrimeGaps.primeGap i ≤ 2 := by exact_mod_cast h2
    omega
  · intro h
    rw [h]
    norm_num

/-! ### Rigidity: the prime staircase jumps only at even scales -/

/-- **Even-scale rigidity of the prime Betti curve.**  For `k ≥ 1` the Betti number of the
prime cloud is constant on the scale window `[2k, 2k + 2)`: the prime `H₀` staircase can
only jump at even integers (and once, at scale `1`). -/
theorem prime_bettiZero_const_on_even_window {k : ℕ} (hk : 1 ≤ k) (n : ℕ) {ε : ℝ}
    (h1 : (2 * k : ℝ) ≤ ε) (h2 : ε < 2 * k + 2) :
    PrimeBarcode.bettiZero PrimePH.P ε n = PrimeBarcode.bettiZero PrimePH.P (2 * k) n := by
  classical
  rw [PrimeBarcode.prime_bettiZero_eq, PrimeBarcode.prime_bettiZero_eq]
  congr 2
  apply Finset.filter_congr
  intro i _
  constructor
  · intro hgt
    exact lt_of_le_of_lt h1 hgt
  · intro hgt
    -- the bar length is an even natural number exceeding `2k`, hence at least `2k + 2`
    rcases Nat.eq_zero_or_pos i with rfl | hi
    · exfalso
      rw [PrimeBarcodeArith.primeGap_zero] at hgt
      have : (2 : ℝ) * 1 ≤ 2 * (k : ℝ) := by
        have : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
        linarith
      norm_num at hgt
      linarith
    · obtain ⟨m, hm⟩ := PrimeBarcodeArith.primeGap_even hi
      have hnat : 2 * k < TwinPrimeGaps.primeGap i := by exact_mod_cast hgt
      have hge : 2 * k + 2 ≤ TwinPrimeGaps.primeGap i := by omega
      have : ((2 * k + 2 : ℕ) : ℝ) ≤ (TwinPrimeGaps.primeGap i : ℝ) := Nat.cast_le.mpr hge
      push_cast at this
      linarith

/-! ### Running the telescope backwards: an arithmetic consequence -/

/-- The atomic bar-length spectrum forces the primes to grow at least linearly with slope
`2`: `p_n ≥ 2n + 1` for `n ≥ 1`. -/
theorem two_mul_add_one_le_nth_prime {n : ℕ} (hn : 1 ≤ n) :
    2 * n + 1 ≤ Nat.nth Nat.Prime n := by
  induction n with
  | zero => omega
  | succ m ih =>
      rcases Nat.eq_zero_or_pos m with rfl | hm
      · simp
      · have hgap : 2 ≤ TwinPrimeGaps.primeGap m := by
          obtain ⟨t, ht⟩ := PrimeBarcodeArith.primeGap_even hm
          have := PrimeBarcodeArith.primeGap_pos m
          omega
        have hmono : Nat.nth Nat.Prime m < Nat.nth Nat.Prime (m + 1) :=
          Nat.nth_strictMono Nat.infinite_setOf_prime (Nat.lt_succ_self m)
        have hprev := ih hm
        unfold TwinPrimeGaps.primeGap at hgap
        omega

/-- **Linear lower bound for the total persistence of the prime barcode.**  Aggregating the
bar lengths, the total persistence of the first `n` bars is at least `2n - 1`. -/
theorem totalPersistence_lower_bound {n : ℕ} (hn : 1 ≤ n) :
    (2 * n : ℝ) - 1 ≤ PrimeBarcode.totalPersistence PrimePH.P n := by
  rw [PrimeBarcode.prime_totalPersistence]
  have h : ((2 * n + 1 : ℕ) : ℝ) ≤ ((Nat.nth Nat.Prime n : ℕ) : ℝ) :=
    Nat.cast_le.mpr (two_mul_add_one_le_nth_prime hn)
  push_cast at h
  linarith

end PrimeRigid