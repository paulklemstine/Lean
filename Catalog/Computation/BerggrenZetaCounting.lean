import Computation.BerggrenZetaAbscissa

/-!
# Counting Berggren-tree triples with hypotenuse at most `H`

Let `N(H)` be the number of nodes of the Berggren tree whose hypotenuse is at most `H`
(equivalently, by `seed_complete`, the number of primitive Pythagorean triples with odd first
leg and hypotenuse `≤ H`).

## Main results

* `N_le` : `N(H) ≤ 2H`.  Every node with `c ≤ H` has Euclid seed `(m,n)` with `n < m ≤ √H`.
* `N_ge_of_sq` : `N(2M²) ≥ (11/144) M² − M/4` for every `M`.  This is an elementary sieve:
  the `M(M−1)/2` pairs `1 ≤ n < m ≤ M` minus the pairs with a common divisor `d ≥ 2`
  (whose number is at most `(M²/2)·Σ_{d≥2} d^{-2} ≤ (25/72) M²`) leaves at least
  `(11/72)M²` coprime pairs, at least half of which have opposite parity — via the
  involution `(m,n) ↦ ((m+n)/2, (m−n)/2)` which turns odd–odd coprime pairs into
  opposite-parity ones.
* `N_ge_of_large` : `N(H) ≥ H/50` for `H ≥ 512`.
* `N_theta` : **`N(H) = Θ(H)`** with explicit constants: `H/50 ≤ N(H) ≤ 2H` for `H ≥ 512`.

Together with `zetaAbscissa_eq_one` this is the sharp counting statement behind the abscissa:
the number of Berggren-generated triples below `H` really is of exact order `H`, not of the
order `H^{log 3/log(3+2√2)}` predicted by the silver-ratio layer heuristic.
-/

namespace BerggrenZeta

open Finset

instance : DecidablePred IsSeed := fun p =>
  decidable_of_iff (0 < p.2 ∧ p.2 < p.1 ∧ Nat.Coprime p.1 p.2 ∧ (p.1 + p.2) % 2 = 1)
    ⟨fun h => ⟨h.1, h.2.1, h.2.2.1, h.2.2.2⟩, fun h => ⟨h.pos, h.lt, h.cop, h.parity⟩⟩

/-- The set of Berggren nodes (in Euclid-seed coordinates) with hypotenuse at most `H`. -/
def seedsBelow (H : ℕ) : Finset (ℕ × ℕ) :=
  ((range (H + 1)) ×ˢ (range (H + 1))).filter (fun p => IsSeed p ∧ hyp p ≤ H)

/-- The counting function of the Berggren tree. -/
def N (H : ℕ) : ℕ := (seedsBelow H).card

lemma mem_seedsBelow {H : ℕ} {p : ℕ × ℕ} : p ∈ seedsBelow H ↔ IsSeed p ∧ hyp p ≤ H := by
  constructor
  · intro h
    exact (mem_filter.1 h).2
  · rintro ⟨hs, hh⟩
    refine mem_filter.2 ⟨?_, hs, hh⟩
    have h1 : 1 ≤ p.2 := hs.pos
    have h2 : p.2 < p.1 := hs.lt
    have hm : p.1 ≤ H := by
      have : p.1 ^ 2 ≤ hyp p := by unfold hyp; nlinarith
      nlinarith
    exact mem_product.2 ⟨mem_range.2 (by omega), mem_range.2 (by omega)⟩

/-- The elements counted by `N` are exactly the nodes of the tree with small hypotenuse. -/
theorem mem_seedsBelow_iff_node {H : ℕ} {p : ℕ × ℕ} :
    p ∈ seedsBelow H ↔ ∃ w : List (Fin 3), node w = p ∧ chyp w ≤ H := by
  rw [mem_seedsBelow]
  constructor
  · rintro ⟨hs, hh⟩
    obtain ⟨w, hw⟩ := seed_complete p hs
    exact ⟨w, hw, by rw [chyp, hw]; exact hh⟩
  · rintro ⟨w, hw, hh⟩
    subst hw
    exact ⟨isSeed_node w, hh⟩

lemma seedsBelow_mono {H₁ H₂ : ℕ} (h : H₁ ≤ H₂) : seedsBelow H₁ ⊆ seedsBelow H₂ := by
  intro p hp
  rw [mem_seedsBelow] at hp ⊢
  exact ⟨hp.1, hp.2.trans h⟩

theorem N_mono {H₁ H₂ : ℕ} (h : H₁ ≤ H₂) : N H₁ ≤ N H₂ :=
  card_le_card (seedsBelow_mono h)

/-! ## The upper bound `N(H) ≤ 2H` -/

theorem N_le (H : ℕ) : N H ≤ 2 * H := by
  set K := Nat.sqrt H with hK
  have hsub : seedsBelow H ⊆ (Icc 1 K) ×ˢ (range (K + 1)) := by
    intro p hp
    rw [mem_seedsBelow] at hp
    obtain ⟨hs, hh⟩ := hp
    have h1 : 1 ≤ p.2 := hs.pos
    have h2 : p.2 < p.1 := hs.lt
    have hm2 : p.1 ^ 2 ≤ H := by
      have : p.1 ^ 2 ≤ hyp p := by unfold hyp; nlinarith
      omega
    have hmK : p.1 ≤ K := by
      rw [hK]
      exact Nat.le_sqrt.2 (by nlinarith)
    exact mem_product.2 ⟨mem_Icc.2 ⟨by omega, hmK⟩, mem_range.2 (by omega)⟩
  have hcard := card_le_card hsub
  rw [card_product, Nat.card_Icc, card_range] at hcard
  have hKH : K * K ≤ H := by
    have := Nat.sqrt_le' H
    rw [pow_two] at this
    exact this
  have hKle : K ≤ H := by
    rcases Nat.eq_zero_or_pos K with h | h
    · omega
    · nlinarith
  calc N H ≤ (K + 1 - 1) * (K + 1) := hcard
    _ = K * K + K := by rw [Nat.add_sub_cancel]; ring
    _ ≤ 2 * H := by omega

/-! ## The sieve lower bound -/

/-- The triangle `{(m,n) : 1 ≤ n < m ≤ M}`. -/
def triSet (M : ℕ) : Finset (ℕ × ℕ) :=
  ((Icc 1 M) ×ˢ (Icc 1 M)).filter (fun p => p.2 < p.1)

lemma mem_triSet {M : ℕ} {p : ℕ × ℕ} :
    p ∈ triSet M ↔ 1 ≤ p.2 ∧ p.2 < p.1 ∧ p.1 ≤ M := by
  simp only [triSet, mem_filter, mem_product, mem_Icc]
  constructor
  · rintro ⟨⟨⟨h1, h2⟩, h3, h4⟩, h5⟩
    exact ⟨h3, h5, h2⟩
  · rintro ⟨h1, h2, h3⟩
    exact ⟨⟨⟨by omega, h3⟩, h1, by omega⟩, h2⟩

lemma card_triSet (M : ℕ) : 2 * (triSet M).card = M * (M - 1) := by
  induction M with
  | zero => decide
  | succ M ih =>
    have hsplit : triSet (M + 1) = triSet M ∪ ((Icc 1 M).image (fun n => (M + 1, n))) := by
      ext p
      simp only [mem_triSet, mem_union, mem_image, mem_Icc]
      constructor
      · rintro ⟨h1, h2, h3⟩
        rcases Nat.lt_or_ge p.1 (M + 1) with h | h
        · exact Or.inl ⟨h1, h2, by omega⟩
        · refine Or.inr ⟨p.2, ⟨h1, by omega⟩, ?_⟩
          exact Prod.ext (by omega) rfl
      · rintro (⟨h1, h2, h3⟩ | ⟨n, ⟨h1, h2⟩, rfl⟩)
        · exact ⟨h1, h2, by omega⟩
        · exact ⟨h1, by show n < M + 1; omega, by show M + 1 ≤ M + 1; exact le_rfl⟩
    have hdisj : Disjoint (triSet M) ((Icc 1 M).image (fun n => (M + 1, n))) := by
      rw [disjoint_left]
      intro p hp hp'
      rw [mem_triSet] at hp
      simp only [mem_image, mem_Icc] at hp'
      obtain ⟨n, -, rfl⟩ := hp'
      simp at hp
    rw [hsplit, card_union_of_disjoint hdisj, card_image_of_injective _ (by
      intro a b hab
      simpa using hab), Nat.card_Icc]
    rcases Nat.eq_zero_or_pos M with rfl | hM
    · norm_num [triSet]
    · obtain ⟨k, rfl⟩ : ∃ k, M = k + 1 := ⟨M - 1, by omega⟩
      have ih' : 2 * (triSet (k + 1)).card = (k + 1) * k := by simpa using ih
      have hexp : (k + 1 + 1) * (k + 1 + 1 - 1) = (k + 1) * k + 2 * (k + 1) := by
        simp only [Nat.add_sub_cancel]
        ring
      rw [hexp, Nat.add_sub_cancel]
      linarith [ih']

/-- The pairs in the triangle both of whose coordinates are divisible by `d`. -/
def badSet (M d : ℕ) : Finset (ℕ × ℕ) := (triSet M).filter (fun p => d ∣ p.1 ∧ d ∣ p.2)

lemma card_badSet_le {M d : ℕ} (hd : 2 ≤ d) : (badSet M d).card ≤ (triSet (M / d)).card := by
  refine card_le_card_of_injOn (fun p => (p.1 / d, p.2 / d)) ?_ ?_
  · intro p hp
    obtain ⟨hp1, hd1, hd2⟩ := Finset.mem_filter.1 hp
    obtain ⟨h1, h2, h3⟩ := mem_triSet.1 hp1
    refine Finset.mem_coe.2 (mem_triSet.2 ⟨?_, ?_, Nat.div_le_div_right h3⟩)
    · exact Nat.one_le_div_iff (by omega) |>.2 (Nat.le_of_dvd (by omega) hd2)
    · exact Nat.div_lt_div_of_lt_of_dvd hd1 h2
  · intro p hp q hq hpq
    obtain ⟨-, hpd1, hpd2⟩ := Finset.mem_filter.1 (Finset.mem_coe.1 hp)
    obtain ⟨-, hqd1, hqd2⟩ := Finset.mem_filter.1 (Finset.mem_coe.1 hq)
    simp only [Prod.mk.injEq] at hpq
    have h1 : p.1 = q.1 := by
      have := congrArg (fun x => x * d) hpq.1
      simpa [Nat.div_mul_cancel hpd1, Nat.div_mul_cancel hqd1] using this
    have h2 : p.2 = q.2 := by
      have := congrArg (fun x => x * d) hpq.2
      simpa [Nat.div_mul_cancel hpd2, Nat.div_mul_cancel hqd2] using this
    exact Prod.ext h1 h2

/-- The coprime pairs in the triangle. -/
def copSet (M : ℕ) : Finset (ℕ × ℕ) := (triSet M).filter (fun p => Nat.Coprime p.1 p.2)

lemma triSet_subset_cop_union_bad (M : ℕ) :
    triSet M ⊆ copSet M ∪ (Icc 2 M).biUnion (badSet M) := by
  intro p hp
  by_cases hc : Nat.Coprime p.1 p.2
  · exact mem_union_left _ (mem_filter.2 ⟨hp, hc⟩)
  · refine mem_union_right _ (mem_biUnion.2 ⟨Nat.gcd p.1 p.2, ?_, ?_⟩)
    · rw [mem_triSet] at hp
      rw [mem_Icc]
      constructor
      · rcases Nat.lt_or_ge (Nat.gcd p.1 p.2) 2 with h | h
        · interval_cases h' : Nat.gcd p.1 p.2
          · exfalso
            have := Nat.eq_zero_of_gcd_eq_zero_left h'
            omega
          · exact absurd h' hc
        · exact h
      · exact le_trans (Nat.le_of_dvd (by omega) (Nat.gcd_dvd_left _ _)) hp.2.2
    · exact mem_filter.2 ⟨hp, Nat.gcd_dvd_left _ _, Nat.gcd_dvd_right _ _⟩

lemma card_triSet_le (M : ℕ) :
    (triSet M).card ≤ (copSet M).card + ∑ d ∈ Icc 2 M, (badSet M d).card := by
  calc (triSet M).card ≤ (copSet M ∪ (Icc 2 M).biUnion (badSet M)).card :=
        card_le_card (triSet_subset_cop_union_bad M)
    _ ≤ (copSet M).card + ((Icc 2 M).biUnion (badSet M)).card := card_union_le _ _
    _ ≤ (copSet M).card + ∑ d ∈ Icc 2 M, (badSet M d).card := by
        exact Nat.add_le_add_left (card_biUnion_le) _

/-! ### The tail estimate `Σ_{d ≥ 2} d^{-2} ≤ 25/36` -/

lemma sum_inv_sq_le (M : ℕ) : ∑ d ∈ Icc 2 M, (1 : ℝ) / (d : ℝ) ^ 2 ≤ 25 / 36 := by
  rcases Nat.lt_or_ge M 3 with hM | hM
  · interval_cases M <;> norm_num [Finset.sum_Icc_succ_top]
  · have key : ∀ M : ℕ, 3 ≤ M →
        ∑ d ∈ Icc 2 M, (1 : ℝ) / (d : ℝ) ^ 2 ≤ 25 / 36 - 1 / (M : ℝ) := by
      intro M hM
      induction M, hM using Nat.le_induction with
      | base => norm_num [show Icc 2 3 = {2, 3} from rfl]
      | succ M hM ih =>
        rw [Finset.sum_Icc_succ_top (by omega)]
        have hMpos : (0 : ℝ) < (M : ℝ) := by
          have : (3 : ℝ) ≤ (M : ℝ) := by exact_mod_cast hM
          linarith
        have hM1 : ((M : ℝ) + 1) = ((M + 1 : ℕ) : ℝ) := by push_cast; ring
        have hstep : (1 : ℝ) / ((M + 1 : ℕ) : ℝ) ^ 2 ≤ 1 / (M : ℝ) - 1 / ((M + 1 : ℕ) : ℝ) := by
          rw [← hM1]
          have e : 1 / (M : ℝ) - 1 / ((M : ℝ) + 1) = 1 / ((M : ℝ) * ((M : ℝ) + 1)) := by
            field_simp
            ring
          rw [e]
          refine one_div_le_one_div_of_le (by positivity) ?_
          nlinarith
        linarith [ih]
    have h := key M hM
    have hMpos : (0 : ℝ) < (M : ℝ) := by
      have : (3 : ℝ) ≤ (M : ℝ) := by exact_mod_cast hM
      linarith
    have : (0 : ℝ) < 1 / (M : ℝ) := by positivity
    linarith

/-! ### The coprime count -/

lemma card_copSet_ge (M : ℕ) :
    ((11 : ℝ) / 72) * (M : ℝ) ^ 2 - (M : ℝ) / 2 ≤ ((copSet M).card : ℝ) := by
  -- the triangle has `M(M-1)/2` elements
  have htri : 2 * ((triSet M).card : ℝ) = (M : ℝ) * ((M : ℝ) - 1) := by
    rcases Nat.eq_zero_or_pos M with rfl | hM
    · simp [triSet]
    · have h := card_triSet M
      have hcast : ((2 * (triSet M).card : ℕ) : ℝ) = ((M * (M - 1) : ℕ) : ℝ) := by rw [h]
      push_cast [Nat.cast_sub (by omega : 1 ≤ M)] at hcast
      linarith
  -- each bad set is small
  have hbad : ∀ d ∈ Icc 2 M, ((badSet M d).card : ℝ) ≤ (M : ℝ) ^ 2 / (2 * (d : ℝ) ^ 2) := by
    intro d hd
    rw [mem_Icc] at hd
    have hdle : ((badSet M d).card : ℝ) ≤ ((triSet (M / d)).card : ℝ) := by
      exact_mod_cast card_badSet_le hd.1
    have hk : 2 * ((triSet (M / d)).card : ℝ) = ((M / d : ℕ) : ℝ) * (((M / d : ℕ) : ℝ) - 1) := by
      rcases Nat.eq_zero_or_pos (M / d) with h | h
      · rw [h]
        norm_num [triSet]
      · have hc := card_triSet (M / d)
        have hcast : ((2 * (triSet (M / d)).card : ℕ) : ℝ) = ((M / d * (M / d - 1) : ℕ) : ℝ) := by
          rw [hc]
        push_cast [Nat.cast_sub (by omega : 1 ≤ M / d)] at hcast
        linarith
    have hdiv : ((M / d : ℕ) : ℝ) ≤ (M : ℝ) / (d : ℝ) := Nat.cast_div_le
    have hd0 : (0 : ℝ) < (d : ℝ) := by
      have : (2 : ℝ) ≤ (d : ℝ) := by exact_mod_cast hd.1
      linarith
    have hnn : (0 : ℝ) ≤ ((M / d : ℕ) : ℝ) := Nat.cast_nonneg _
    have hsq : ((M / d : ℕ) : ℝ) * (((M / d : ℕ) : ℝ) - 1) ≤ (M : ℝ) ^ 2 / (d : ℝ) ^ 2 := by
      have h1 : ((M / d : ℕ) : ℝ) * (((M / d : ℕ) : ℝ) - 1) ≤ ((M / d : ℕ) : ℝ) ^ 2 := by
        nlinarith
      have h2 : ((M / d : ℕ) : ℝ) ^ 2 ≤ ((M : ℝ) / (d : ℝ)) ^ 2 := by
        have hMnn : (0 : ℝ) ≤ (M : ℝ) / (d : ℝ) := by positivity
        nlinarith
      calc ((M / d : ℕ) : ℝ) * (((M / d : ℕ) : ℝ) - 1) ≤ ((M : ℝ) / (d : ℝ)) ^ 2 := by linarith
        _ = (M : ℝ) ^ 2 / (d : ℝ) ^ 2 := by rw [div_pow]
    have hhalf : (M : ℝ) ^ 2 / (2 * (d : ℝ) ^ 2) = ((M : ℝ) ^ 2 / (d : ℝ) ^ 2) / 2 := by
      field_simp
    rw [hhalf]
    linarith
  have hsum : (∑ d ∈ Icc 2 M, ((badSet M d).card : ℝ))
      ≤ ((M : ℝ) ^ 2 / 2) * ∑ d ∈ Icc 2 M, (1 : ℝ) / (d : ℝ) ^ 2 := by
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum ?_
    intro d hd
    have := hbad d hd
    have hd0 : (0 : ℝ) < (d : ℝ) := by
      rw [mem_Icc] at hd
      have : (2 : ℝ) ≤ (d : ℝ) := by exact_mod_cast hd.1
      linarith
    calc ((badSet M d).card : ℝ) ≤ (M : ℝ) ^ 2 / (2 * (d : ℝ) ^ 2) := this
      _ = (M : ℝ) ^ 2 / 2 * (1 / (d : ℝ) ^ 2) := by field_simp
  have htail := sum_inv_sq_le M
  have hMnn : (0 : ℝ) ≤ (M : ℝ) ^ 2 / 2 := by positivity
  have hle : (∑ d ∈ Icc 2 M, ((badSet M d).card : ℝ)) ≤ (25 / 72) * (M : ℝ) ^ 2 := by
    calc (∑ d ∈ Icc 2 M, ((badSet M d).card : ℝ))
        ≤ ((M : ℝ) ^ 2 / 2) * ∑ d ∈ Icc 2 M, (1 : ℝ) / (d : ℝ) ^ 2 := hsum
      _ ≤ ((M : ℝ) ^ 2 / 2) * (25 / 36) := by nlinarith
      _ = (25 / 72) * (M : ℝ) ^ 2 := by ring
  have hcard : ((triSet M).card : ℝ)
      ≤ ((copSet M).card : ℝ) + ∑ d ∈ Icc 2 M, ((badSet M d).card : ℝ) := by
    have := card_triSet_le M
    have hcast : ((triSet M).card : ℝ)
        ≤ (((copSet M).card + ∑ d ∈ Icc 2 M, (badSet M d).card : ℕ) : ℝ) := by
      exact_mod_cast this
    push_cast at hcast
    linarith
  linarith

/-! ### Half of the coprime pairs have opposite parity -/

/-- The coprime pairs of opposite parity, i.e. the Euclid seeds with `m ≤ M`. -/
def oppSet (M : ℕ) : Finset (ℕ × ℕ) := (copSet M).filter (fun p => (p.1 + p.2) % 2 = 1)

lemma card_copSet_le_two_mul (M : ℕ) : (copSet M).card ≤ 2 * (oppSet M).card := by
  classical
  set oddSet : Finset (ℕ × ℕ) := (copSet M).filter (fun p => (p.1 + p.2) % 2 = 0) with hodd
  have heq : (copSet M).filter (fun p => ¬ ((p.1 + p.2) % 2 = 1)) = oddSet := by
    rw [hodd]
    refine Finset.filter_congr ?_
    intro x _
    constructor <;> intro h <;> omega
  have hsplit : (copSet M).card = (oppSet M).card + oddSet.card := by
    have hcf := Finset.card_filter_add_card_filter_not (s := copSet M)
      (p := fun p : ℕ × ℕ => (p.1 + p.2) % 2 = 1)
    rw [heq] at hcf
    rw [oppSet]
    omega
  have hinj : oddSet.card ≤ (oppSet M).card := by
    refine card_le_card_of_injOn (fun p => ((p.1 + p.2) / 2, (p.1 - p.2) / 2)) ?_ ?_
    · intro p hp
      rw [hodd] at hp
      obtain ⟨hp1, hpar⟩ := Finset.mem_filter.1 hp
      obtain ⟨hp2, hcop⟩ := Finset.mem_filter.1 hp1
      obtain ⟨h1, h2, h3⟩ := mem_triSet.1 hp2
      -- both coordinates are odd
      have hodd1 : p.1 % 2 = 1 := by
        rcases Nat.even_or_odd p.1 with he | ho
        · exfalso
          have he2 : p.1 % 2 = 0 := Nat.even_iff.1 he
          have he3 : p.2 % 2 = 0 := by omega
          have : 2 ∣ Nat.gcd p.1 p.2 := Nat.dvd_gcd (by omega) (by omega)
          rw [hcop] at this
          omega
        · exact Nat.odd_iff.1 ho
      have hodd2 : p.2 % 2 = 1 := by omega
      have hgap : p.2 + 2 ≤ p.1 := by omega
      have hcophalf : Nat.Coprime ((p.1 + p.2) / 2) ((p.1 - p.2) / 2) := by
        set a := (p.1 + p.2) / 2 with ha
        set b := (p.1 - p.2) / 2 with hb
        have hab : a + b = p.1 := by omega
        have hab' : a - b = p.2 := by omega
        have hd1 : Nat.gcd a b ∣ p.1 := hab ▸ Nat.dvd_add (Nat.gcd_dvd_left _ _)
          (Nat.gcd_dvd_right _ _)
        have hd2 : Nat.gcd a b ∣ p.2 := by
          have := Nat.dvd_sub (Nat.gcd_dvd_left a b) (Nat.gcd_dvd_right a b)
          rwa [hab'] at this
        have hdd : Nat.gcd a b ∣ Nat.gcd p.1 p.2 := Nat.dvd_gcd hd1 hd2
        rw [hcop] at hdd
        exact Nat.eq_one_of_dvd_one hdd
      have hmemcop : ((p.1 + p.2) / 2, (p.1 - p.2) / 2) ∈ copSet M := by
        rw [copSet]
        exact Finset.mem_filter.2 ⟨mem_triSet.2 ⟨by omega, by omega, by omega⟩, hcophalf⟩
      refine Finset.mem_coe.2 ?_
      rw [oppSet]
      refine Finset.mem_filter.2 ⟨hmemcop, ?_⟩
      show ((p.1 + p.2) / 2 + (p.1 - p.2) / 2) % 2 = 1
      omega
    · intro p hp q hq hpq
      rw [hodd] at hp hq
      obtain ⟨hpa, hppar⟩ := Finset.mem_filter.1 (Finset.mem_coe.1 hp)
      obtain ⟨hqa, hqpar⟩ := Finset.mem_filter.1 (Finset.mem_coe.1 hq)
      obtain ⟨hp1, hp2, hp3⟩ := mem_triSet.1 (Finset.mem_filter.1 hpa).1
      obtain ⟨hq1, hq2, hq3⟩ := mem_triSet.1 (Finset.mem_filter.1 hqa).1
      simp only [Prod.mk.injEq] at hpq
      exact Prod.ext (by omega) (by omega)
  omega

/-! ### Putting the sieve together -/

lemma oppSet_subset_seedsBelow (M : ℕ) : oppSet M ⊆ seedsBelow (2 * M ^ 2) := by
  intro p hp
  rw [oppSet] at hp
  obtain ⟨hp1, hpar⟩ := Finset.mem_filter.1 hp
  rw [copSet] at hp1
  obtain ⟨hp2, hcop⟩ := Finset.mem_filter.1 hp1
  obtain ⟨h1, h2, h3⟩ := mem_triSet.1 hp2
  rw [mem_seedsBelow]
  refine ⟨⟨by omega, h2, hcop, hpar⟩, ?_⟩
  unfold hyp
  nlinarith

/-- **The sieve lower bound.** -/
theorem N_ge_of_sq (M : ℕ) : ((11 : ℝ) / 144) * (M : ℝ) ^ 2 - (M : ℝ) / 4 ≤ (N (2 * M ^ 2) : ℝ) := by
  have h1 : (oppSet M).card ≤ N (2 * M ^ 2) := card_le_card (oppSet_subset_seedsBelow M)
  have h2 := card_copSet_le_two_mul M
  have h3 := card_copSet_ge M
  have h2' : ((copSet M).card : ℝ) ≤ 2 * ((oppSet M).card : ℝ) := by exact_mod_cast h2
  have h1' : ((oppSet M).card : ℝ) ≤ (N (2 * M ^ 2) : ℝ) := by exact_mod_cast h1
  linarith

/-- **The lower bound `N(H) ≥ H/50` for `H ≥ 512`.** -/
theorem N_ge_of_large {H : ℕ} (hH : 512 ≤ H) : (H : ℝ) / 50 ≤ (N H : ℝ) := by
  set M := Nat.sqrt (H / 2) with hM
  have hMsq : M * M ≤ H / 2 := by
    have := Nat.sqrt_le' (H / 2)
    rw [pow_two] at this
    exact this
  have h2M : 2 * M ^ 2 ≤ H := by
    have : M ^ 2 = M * M := by ring
    omega
  have hM16 : 16 ≤ M := by
    rw [hM]
    exact Nat.le_sqrt.2 (by omega)
  have hlt : H / 2 < (M + 1) * (M + 1) := by
    have := Nat.lt_succ_sqrt' (H / 2)
    rw [pow_two] at this
    exact this
  have hH3 : H ≤ 3 * M ^ 2 := by
    have hmm : (M + 1) * (M + 1) = M * M + 2 * M + 1 := by ring
    have hsq : M ^ 2 = M * M := by ring
    have h16M : 16 * M ≤ M * M := Nat.mul_le_mul_right M hM16
    omega
  have hmono : (N (2 * M ^ 2) : ℝ) ≤ (N H : ℝ) := by
    exact_mod_cast N_mono h2M
  have hsieve := N_ge_of_sq M
  have hMR : (16 : ℝ) ≤ (M : ℝ) := by exact_mod_cast hM16
  have hHR : (H : ℝ) ≤ 3 * (M : ℝ) ^ 2 := by exact_mod_cast hH3
  nlinarith

/-- **`N(H) = Θ(H)`** with explicit constants. -/
theorem N_theta {H : ℕ} (hH : 512 ≤ H) : (H : ℝ) / 50 ≤ (N H : ℝ) ∧ (N H : ℝ) ≤ 2 * (H : ℝ) := by
  refine ⟨N_ge_of_large hH, ?_⟩
  exact_mod_cast N_le H

end BerggrenZeta