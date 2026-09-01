/-
# The symmetrization-defect law

The two degree-12 findings proved in `D12SemiprimePairLaw` and
`D12SemiprimeWhichFactorWall` — the exact `φ`-enumeration law for the semiprime
type pair, and the which-factor wall on the `114` asymmetric exponent pairs —
turn out to be two faces of a single identity, valid for **every** cyclic order
`n > 0`:

  `H(Π) = 2 H(T) − #asym(n) / n²`.

In words: the entropy of the *unordered* splitting-type pair of a semiprime is
twice the entropy of a single splitting type, minus exactly the probability that
the two primes have *different* splitting types.  The defect is precisely the
population on which the which-factor question is meaningful — the population on
which the wall of `D12SemiprimeWhichFactorWall` operates.

Equivalently `#asym(n) = n² − ∑_{d ∣ n} φ(d)²`, so the law reads

  `H(Π) = 2 H(T) − 1 + (∑_{d ∣ n} φ(d)²)/n²`.

Sanity checks against the independently enumerated values of
`Shared.CyclicTypeChannelValues` are given at the end for
`n = 2, 4, 6, 10, 12, 16`; the degree-12 instance is `7/8 + 2 log₂ 3
= 2(5/6 + log₂ 3) − 114/144`.
-/
import Combinatorics.D12SemiprimePairLaw
import Combinatorics.D12SemiprimeWhichFactorWall

namespace CyclicTypeChannel

open Finset

/-! ## 1. Symmetric sums over a square -/

/-- The diagonal of a square index set is a copy of the index set. -/
lemma sum_over_diag (D : Finset ℕ) (g : ℕ × ℕ → ℝ) :
    ∑ t ∈ {t ∈ D ×ˢ D | t.1 = t.2}, g t = ∑ d ∈ D, g (d, d) := by
  classical
  have himg : {t ∈ D ×ˢ D | t.1 = t.2} = D.image (fun d => (d, d)) := by
    ext ⟨a, b⟩
    simp only [mem_filter, mem_product, mem_image, Prod.mk.injEq]
    constructor
    · rintro ⟨⟨ha, hb⟩, rfl⟩
      exact ⟨a, ha, rfl, rfl⟩
    · rintro ⟨d, hd, rfl, rfl⟩
      exact ⟨⟨hd, hd⟩, rfl⟩
  rw [himg, Finset.sum_image (by intro x _ y _ h; exact (Prod.mk.injEq _ _ _ _ ▸ h).1)]

/-- The strict upper and lower triangles of a square carry the same symmetric
sum. -/
lemma sum_lower_eq_upper (D : Finset ℕ) (g : ℕ × ℕ → ℝ) (hg : ∀ a b, g (a, b) = g (b, a)) :
    ∑ t ∈ {t ∈ D ×ˢ D | t.2 < t.1}, g t = ∑ t ∈ {t ∈ D ×ˢ D | t.1 < t.2}, g t := by
  classical
  have himg : {t ∈ D ×ˢ D | t.2 < t.1} = ({t ∈ D ×ˢ D | t.1 < t.2}).image Prod.swap := by
    ext ⟨a, b⟩
    simp only [mem_filter, mem_product, mem_image, Prod.exists, Prod.swap_prod_mk,
      Prod.mk.injEq]
    constructor
    · rintro ⟨⟨ha, hb⟩, hlt⟩
      exact ⟨b, a, ⟨⟨hb, ha⟩, hlt⟩, rfl, rfl⟩
    · rintro ⟨x, y, ⟨⟨hx, hy⟩, hlt⟩, rfl, rfl⟩
      exact ⟨⟨hy, hx⟩, hlt⟩
  rw [himg, Finset.sum_image (by intro x _ y _ h; exact Prod.swap_injective h)]
  refine Finset.sum_congr rfl fun t _ => ?_
  obtain ⟨a, b⟩ := t
  exact hg b a

/-- **Symmetric split of a square sum**: diagonal plus twice the strict upper
triangle. -/
lemma sum_symm_split (D : Finset ℕ) (g : ℕ × ℕ → ℝ) (hg : ∀ a b, g (a, b) = g (b, a)) :
    ∑ t ∈ D ×ˢ D, g t
      = ∑ t ∈ {t ∈ D ×ˢ D | t.1 = t.2}, g t + 2 * ∑ t ∈ {t ∈ D ×ˢ D | t.1 < t.2}, g t := by
  classical
  have hdisj : Disjoint {t ∈ D ×ˢ D | t.1 < t.2} {t ∈ D ×ˢ D | t.2 < t.1} := by
    rw [Finset.disjoint_left]
    intro t ht ht'
    simp only [mem_filter] at ht ht'
    omega
  have hne : {t ∈ D ×ˢ D | ¬ (t.1 = t.2)}
      = {t ∈ D ×ˢ D | t.1 < t.2} ∪ {t ∈ D ×ˢ D | t.2 < t.1} := by
    rw [← Finset.filter_or]
    exact Finset.filter_congr fun t _ => by omega
  have h1 : ∑ t ∈ D ×ˢ D, g t
      = ∑ t ∈ {t ∈ D ×ˢ D | t.1 = t.2}, g t + ∑ t ∈ {t ∈ D ×ˢ D | ¬ (t.1 = t.2)}, g t :=
    (Finset.sum_filter_add_sum_filter_not _ _ _).symm
  rw [h1, hne, Finset.sum_union hdisj, sum_lower_eq_upper D g hg]
  ring

/-- The set of unordered divisor pairs splits as diagonal plus strict upper
triangle. -/
lemma sum_divPairs_split (n : ℕ) (g : ℕ × ℕ → ℝ) :
    ∑ t ∈ divPairs n, g t
      = ∑ t ∈ {t ∈ n.divisors ×ˢ n.divisors | t.1 = t.2}, g t
        + ∑ t ∈ {t ∈ n.divisors ×ˢ n.divisors | t.1 < t.2}, g t := by
  classical
  set D := n.divisors
  have hdisj : Disjoint {t ∈ D ×ˢ D | t.1 = t.2} {t ∈ D ×ˢ D | t.1 < t.2} := by
    rw [Finset.disjoint_left]
    intro t ht ht'
    simp only [mem_filter] at ht ht'
    omega
  have hset : divPairs n = {t ∈ D ×ˢ D | t.1 = t.2} ∪ {t ∈ D ×ˢ D | t.1 < t.2} := by
    rw [← Finset.filter_or]
    exact Finset.filter_congr fun t _ => by omega
  rw [hset, Finset.sum_union hdisj]

/-! ## 2. The counting identity behind the law -/

/-- The `φ`-weighted symmetric kernel. -/
private noncomputable def aKer (t : ℕ × ℕ) : ℝ :=
  (Nat.totient t.1 : ℝ) * (Nat.totient t.2 : ℝ) *
    (Real.logb 2 (Nat.totient t.1 : ℝ) + Real.logb 2 (Nat.totient t.2 : ℝ))

/-- The plain product kernel. -/
private noncomputable def mKer (t : ℕ × ℕ) : ℝ :=
  (Nat.totient t.1 : ℝ) * (Nat.totient t.2 : ℝ)

private lemma aKer_symm (a b : ℕ) : aKer (a, b) = aKer (b, a) := by
  simp only [aKer]; ring

private lemma mKer_symm (a b : ℕ) : mKer (a, b) = mKer (b, a) := by
  simp only [mKer]; ring

private lemma totient_pos_of_mem_divisors {n d : ℕ} (hd : d ∈ n.divisors) :
    0 < Nat.totient d :=
  Nat.totient_pos.2 (Nat.pos_of_mem_divisors hd)

/-- On the diagonal the enumeration law's entropy term is the `φ`-kernel. -/
private lemma pairCount_term_diag {n d : ℕ} (hd : d ∈ n.divisors) :
    (pairCount (d, d) : ℝ) * Real.logb 2 (pairCount (d, d) : ℝ) = aKer (d, d) := by
  have hpos : (0 : ℝ) < (Nat.totient d : ℝ) := by
    exact_mod_cast totient_pos_of_mem_divisors hd
  have hc : ((pairCount (d, d) : ℕ) : ℝ) = (Nat.totient d : ℝ) * (Nat.totient d : ℝ) := by
    simp [pairCount]
  rw [hc, Real.logb_mul (ne_of_gt hpos) (ne_of_gt hpos)]
  simp only [aKer]

/-- Off the diagonal the entropy term is twice the `φ`-kernel plus twice the
product kernel — the extra `2 m` is precisely the cost of forgetting the order
of the two primes. -/
private lemma pairCount_term_offdiag {n : ℕ} {t : ℕ × ℕ}
    (h1 : t.1 ∈ n.divisors) (h2 : t.2 ∈ n.divisors) (hlt : t.1 < t.2) :
    (pairCount t : ℝ) * Real.logb 2 (pairCount t : ℝ) = 2 * aKer t + 2 * mKer t := by
  have hp1 : (0 : ℝ) < (Nat.totient t.1 : ℝ) := by
    exact_mod_cast totient_pos_of_mem_divisors h1
  have hp2 : (0 : ℝ) < (Nat.totient t.2 : ℝ) := by
    exact_mod_cast totient_pos_of_mem_divisors h2
  have hne : ¬ (t.1 = t.2) := Nat.ne_of_lt hlt
  have hc : ((pairCount t : ℕ) : ℝ)
      = 2 * ((Nat.totient t.1 : ℝ) * (Nat.totient t.2 : ℝ)) := by
    simp [pairCount, hne]
  rw [hc, Real.logb_mul (by norm_num) (by positivity),
    Real.logb_mul (ne_of_gt hp1) (ne_of_gt hp2)]
  simp only [aKer, mKer]
  rw [show Real.logb 2 (2 : ℝ) = 1 by simp]
  ring

/-- The `φ`-kernel sums over the full square to `2 n ∑_d φ(d) log₂ φ(d)`. -/
private lemma sum_aKer (n : ℕ) :
    ∑ t ∈ n.divisors ×ˢ n.divisors, aKer t
      = 2 * (n : ℝ) * ∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d : ℝ) := by
  have hsum : ∑ d ∈ n.divisors, (Nat.totient d : ℝ) = (n : ℝ) := by
    exact_mod_cast congrArg (Nat.cast (R := ℝ)) (Nat.sum_totient n)
  have inner : ∀ d ∈ n.divisors, ∑ e ∈ n.divisors, aKer (d, e)
      = ((Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d : ℝ)) * (n : ℝ)
        + (Nat.totient d : ℝ) *
            ∑ e ∈ n.divisors, (Nat.totient e : ℝ) * Real.logb 2 (Nat.totient e : ℝ) := by
    intro d _
    have step : ∀ e ∈ n.divisors, aKer (d, e)
        = ((Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d : ℝ)) * (Nat.totient e : ℝ)
          + (Nat.totient d : ℝ) * ((Nat.totient e : ℝ) * Real.logb 2 (Nat.totient e : ℝ)) := by
      intro e _
      simp only [aKer]
      ring
    rw [Finset.sum_congr rfl step, Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum,
      hsum]
  rw [Finset.sum_product, Finset.sum_congr rfl inner, Finset.sum_add_distrib, ← Finset.sum_mul,
    ← Finset.sum_mul, hsum]
  ring

/-- The product kernel sums over the full square to `n²`. -/
private lemma sum_mKer (n : ℕ) :
    ∑ t ∈ n.divisors ×ˢ n.divisors, mKer t = (n : ℝ) ^ 2 := by
  have hsum : ∑ d ∈ n.divisors, (Nat.totient d : ℝ) = (n : ℝ) := by
    exact_mod_cast congrArg (Nat.cast (R := ℝ)) (Nat.sum_totient n)
  have inner : ∀ d ∈ n.divisors, ∑ e ∈ n.divisors, mKer (d, e)
      = (Nat.totient d : ℝ) * (n : ℝ) := by
    intro d _
    simp only [mKer]
    rw [← Finset.mul_sum, hsum]
  rw [Finset.sum_product, Finset.sum_congr rfl inner, ← Finset.sum_mul, hsum, sq]

/-- **The counting identity.**  The entropy weight predicted by the enumeration
law decomposes into a "twice a single type" part and a symmetrization defect. -/
theorem sum_pairCount_logb (n : ℕ) :
    ∑ t ∈ divPairs n, (pairCount t : ℝ) * Real.logb 2 (pairCount t : ℝ)
      = 2 * (n : ℝ) * (∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d : ℝ))
        + ((n : ℝ) ^ 2 - ∑ d ∈ n.divisors, (Nat.totient d : ℝ) ^ 2) := by
  classical
  set D := n.divisors with hD
  set Diag := {t ∈ D ×ˢ D | t.1 = t.2} with hDiag
  set Up := {t ∈ D ×ˢ D | t.1 < t.2} with hUp
  -- rewrite the law sum termwise
  have hdiagterm : ∑ t ∈ Diag, (pairCount t : ℝ) * Real.logb 2 (pairCount t : ℝ)
      = ∑ t ∈ Diag, aKer t := by
    refine Finset.sum_congr rfl fun t ht => ?_
    simp only [hDiag, mem_filter, mem_product] at ht
    obtain ⟨⟨h1, -⟩, h2⟩ := ht
    obtain ⟨a, b⟩ := t
    cases h2
    exact pairCount_term_diag h1
  have hupterm : ∑ t ∈ Up, (pairCount t : ℝ) * Real.logb 2 (pairCount t : ℝ)
      = ∑ t ∈ Up, (2 * aKer t + 2 * mKer t) := by
    refine Finset.sum_congr rfl fun t ht => ?_
    simp only [hUp, mem_filter, mem_product] at ht
    exact pairCount_term_offdiag ht.1.1 ht.1.2 ht.2
  have hsplitA := sum_symm_split D aKer aKer_symm
  have hsplitM := sum_symm_split D mKer mKer_symm
  have hdiagM : ∑ t ∈ Diag, mKer t = ∑ d ∈ D, (Nat.totient d : ℝ) ^ 2 := by
    rw [hDiag, sum_over_diag]
    exact Finset.sum_congr rfl fun d _ => by simp [mKer, sq]
  rw [sum_divPairs_split n _, ← hDiag, ← hUp, hdiagterm, hupterm,
    Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
  rw [← sum_aKer n, ← sum_mKer n, ← hD]
  rw [hsplitA, hsplitM, ← hDiag, ← hUp, hdiagM]
  ring

/-! ## 3. The type entropy in count form -/

/-- The single-type entropy in count form. -/
theorem typeEntropy_countForm (n : ℕ) (hn : 0 < n) :
    typeEntropy n = Real.logb 2 (n : ℝ)
      - (∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d : ℝ)) / n := by
  have hcard : ((range n).card : ℝ) = (n : ℝ) := by simp
  rw [typeEntropy, uEnt, sum_logb_fiber, image_ordType n hn, hcard]
  congr 2
  refine Finset.sum_congr rfl fun d hd => ?_
  rw [card_ordType_eq_totient hn (Nat.mem_divisors.1 hd).1]

/-! ## 4. The symmetrization-defect law -/

/-- The diagonal population: pairs of exponents with equal splitting type. -/
theorem card_diag_eq_sum_totient_sq (n : ℕ) (hn : 0 < n) :
    #{p ∈ box n | ordType n p.1 = ordType n p.2} = ∑ d ∈ n.divisors, Nat.totient d ^ 2 := by
  classical
  have hset : {p ∈ box n | ordType n p.1 = ordType n p.2}
      = n.divisors.biUnion
          (fun d => {a ∈ range n | ordType n a = d} ×ˢ {a ∈ range n | ordType n a = d}) := by
    ext ⟨x, y⟩
    simp only [box, mem_filter, mem_product, mem_range, mem_biUnion, Nat.mem_divisors]
    constructor
    · rintro ⟨⟨hx, hy⟩, h⟩
      exact ⟨ordType n x, ⟨ordType_dvd x, hn.ne'⟩, ⟨hx, rfl⟩, ⟨hy, h.symm⟩⟩
    · rintro ⟨d, -, ⟨hx, hx'⟩, ⟨hy, hy'⟩⟩
      exact ⟨⟨hx, hy⟩, by rw [hx', hy']⟩
  have hdisj : (↑n.divisors : Set ℕ).PairwiseDisjoint
      (fun d => {a ∈ range n | ordType n a = d} ×ˢ {a ∈ range n | ordType n a = d}) := by
    intro d _ e _ hde
    simp only [Function.onFun]
    rw [Finset.disjoint_left]
    rintro ⟨x, y⟩ hx hy
    simp only [mem_product, mem_filter] at hx hy
    exact hde (hx.1.2 ▸ hy.1.2 ▸ rfl)
  rw [hset, Finset.card_biUnion hdisj]
  refine Finset.sum_congr rfl fun d hd => ?_
  rw [Finset.card_product, card_ordType_eq_totient hn (Nat.mem_divisors.1 hd).1, sq]

/-- The asymmetric population: `#asym(n) = n² − ∑_{d ∣ n} φ(d)²`. -/
theorem card_asym_eq (n : ℕ) (hn : 0 < n) :
    ((asym n).card : ℝ) = (n : ℝ) ^ 2 - ∑ d ∈ n.divisors, (Nat.totient d : ℝ) ^ 2 := by
  classical
  have hbox : (box n).card = n ^ 2 := by simp [box, sq]
  have hsplit : #{p ∈ box n | ordType n p.1 = ordType n p.2} + (asym n).card = (box n).card := by
    rw [asym]
    exact Finset.card_filter_add_card_filter_not _
  have hdiag := card_diag_eq_sum_totient_sq n hn
  have : ((asym n).card : ℝ) = ((box n).card : ℝ)
      - (#{p ∈ box n | ordType n p.1 = ordType n p.2} : ℝ) := by
    have := congrArg (Nat.cast (R := ℝ)) hsplit
    push_cast at this
    linarith
  rw [this, hdiag, hbox]
  push_cast
  ring

/-- **The symmetrization-defect law.**  For every cyclic order `n > 0`,

  `H(Π) = 2 H(T) − #asym(n) / n²`,

i.e. symmetrizing the ordered pair of splitting types costs exactly the
probability that the two primes have distinct types — the population on which
the which-factor wall operates. -/
theorem pairEntropy_symmetrization_law (n : ℕ) (hn : 0 < n) :
    pairEntropy n = 2 * typeEntropy n - ((asym n).card : ℝ) / (n : ℝ) ^ 2 := by
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  rw [pairEntropy_law n hn, typeEntropy_countForm n hn, sum_pairCount_logb n,
    card_asym_eq n hn, show ((n : ℝ) ^ 2) = (n : ℝ) * (n : ℝ) from sq (n : ℝ),
    Real.logb_mul (ne_of_gt hn') (ne_of_gt hn')]
  field_simp
  ring

/-- Equivalent `φ`-form of the law: `H(Π) = 2 H(T) − 1 + (∑_{d ∣ n} φ(d)²)/n²`. -/
theorem pairEntropy_symmetrization_law_phi (n : ℕ) (hn : 0 < n) :
    pairEntropy n = 2 * typeEntropy n - 1
      + (∑ d ∈ n.divisors, (Nat.totient d : ℝ) ^ 2) / (n : ℝ) ^ 2 := by
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  rw [pairEntropy_symmetrization_law n hn, card_asym_eq n hn]
  field_simp
  ring

/-! ## 5. The symmetrization sandwich -/

/-- **Symmetrizing always costs something.**  For `n ≥ 2` the unordered type
pair of a semiprime carries strictly less than twice the single-type entropy:
the defect is the (positive) chance that the two primes differ in type. -/
theorem pairEntropy_lt_two_typeEntropy (n : ℕ) (hn : 2 ≤ n) :
    pairEntropy n < 2 * typeEntropy n := by
  have hn0 : 0 < n := by omega
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn0
  have hc : (0 : ℝ) < ((asym n).card : ℝ) := by
    exact_mod_cast Finset.card_pos.2 (asym_nonempty hn)
  have hd : 0 < ((asym n).card : ℝ) / (n : ℝ) ^ 2 := div_pos hc (by positivity)
  rw [pairEntropy_symmetrization_law n hn0]
  linarith

/-- **…but never more than one bit.**  The symmetrization defect is a
probability, so the unordered pair is always within one bit of twice the
single-type entropy. -/
theorem two_typeEntropy_sub_one_le_pairEntropy (n : ℕ) (hn : 0 < n) :
    2 * typeEntropy n - 1 ≤ pairEntropy n := by
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hsub : (asym n).card ≤ n ^ 2 := by
    have h2 := Finset.card_le_card (Finset.filter_subset
      (fun p : ℕ × ℕ => ordType n p.1 ≠ ordType n p.2) (box n))
    simpa [asym, box, sq] using h2
  have hle : ((asym n).card : ℝ) / (n : ℝ) ^ 2 ≤ 1 := by
    rw [div_le_one (by positivity)]
    exact_mod_cast hsub
  rw [pairEntropy_symmetrization_law n hn]
  linarith

/-! ## 6. The degree-12 instance and its neighbours -/

/-- **The degree-12 instance of the law**, checked against the independently
enumerated values: `7/8 + 2 log₂ 3 = 2 (5/6 + log₂ 3) − 114/144`. -/
theorem symmetrization_law_twelve :
    pairEntropy 12 = 2 * typeEntropy 12 - 114 / 144 := by
  rw [pairEntropy_symmetrization_law 12 (by norm_num), card_asym_twelve]
  norm_num

/-- The degree-12 defect is exactly the which-factor population `114/144 = 19/24`. -/
theorem defect_twelve : 2 * typeEntropy 12 - pairEntropy 12 = 19 / 24 := by
  rw [symmetrization_law_twelve]
  norm_num

/-- The law reproduces the enumerated degree-12 value. -/
theorem symmetrization_law_twelve_value :
    (2 : ℝ) * typeEntropy 12 - 114 / 144 = (7 / 8 : ℝ) + 2 * Real.logb 2 3 := by
  rw [typeEntropy_val_12]
  ring

/-- The law also reproduces the enumerated values at `n = 4`, `6`, `10` and
`16`, so the symmetrization defect is a genuine cross-order law and not a
degree-12 coincidence. -/
theorem symmetrization_law_neighbours :
    pairEntropy 4 = 2 * typeEntropy 4 - 10 / 16 ∧
    pairEntropy 6 = 2 * typeEntropy 6 - 26 / 36 ∧
    pairEntropy 10 = 2 * typeEntropy 10 - 66 / 100 ∧
    pairEntropy 16 = 2 * typeEntropy 16 - 170 / 256 := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [pairEntropy_val_4, typeEntropy_val_4]; norm_num
  · rw [pairEntropy_val_6, typeEntropy_val_6]; ring
  · rw [pairEntropy_val_10, typeEntropy_val_10]; ring
  · rw [pairEntropy_val_16, typeEntropy_val_16]; norm_num

end CyclicTypeChannel