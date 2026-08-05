import Mathlib
import Combinatorics.RamseyExponentialBounds
import Logic.RamseyAsymmetricGap

/-!
# The off-diagonal binomial obstruction

This file settles conjecture **FD3** of the research thread on exponential bounds
for diagonal Ramsey numbers.

The diagonal statement proved earlier in the thread is that the Erdős–Szekeres
binomial estimate loses only a polynomial factor against `4^k`, so it can never
yield an exponential saving.  FD3 is the two-parameter analogue: on a ratio
window the binomial coefficient `C(s+t, s)` matches the entropy base
`β(s,t)^(s+t) = (s+t)^(s+t) / (s^s t^t)` to within a factor `s+t+1`, so no fixed
`q < 1` can ever be gained.

## Contents

* `RamseyBounds.pow_self_le_succ_mul_choose_mul` : the sharp elementary bound
  `n^n ≤ (n+1) · C(n,k) · k^k · (n-k)^(n-k)` for all `k ≤ n`.  This is the
  "largest term of the binomial distribution" estimate, proved here from scratch
  by unimodality of `k^i (n-k)^(n-i) C(n,i)` plus the binomial theorem.
* `RamseyBounds.not_hasProportionalSaving₂_choose` : FD3 for any parameter set
  containing pairs of arbitrarily large total size.
* `RamseyBounds.not_hasProportionalSaving₂_choose_ratioWindow` : FD3 for every
  nondegenerate ratio window `[a,b] ⊆ (0,1)`.
* `RamseyBounds.hasProportionalSaving₂_choose_of_degenerate_window` : FD3 as
  literally stated is **false** for degenerate windows — an empty ratio window
  satisfies the proportional saving vacuously — so the nondegeneracy hypothesis
  is necessary.
-/

namespace RamseyBounds

/-! ### The largest term of the binomial distribution -/

/-- The `m`-th (unnormalized) term of the binomial distribution with success
count `k` out of `n`. -/
def binomTerm (n k m : ℕ) : ℕ := k ^ m * (n - k) ^ (n - m) * n.choose m

theorem binomTerm_le_succ {n k : ℕ} (hk : k ≤ n) {i : ℕ} (hi : i < k) :
    binomTerm n k i ≤ binomTerm n k (i + 1) := by
  have hkey : n.choose i * (n - k) ≤ n.choose (i + 1) * k := by
    have hmul : n.choose i * (n - k) * (i + 1) ≤ n.choose (i + 1) * k * (i + 1) := by
      have h1 : (n - k) * (i + 1) ≤ (n - i) * k := by
        have ha : (n - k) * (i + 1) ≤ (n - k) * k := Nat.mul_le_mul_left _ (by omega)
        have hb : (n - k) * k ≤ (n - i) * k := Nat.mul_le_mul_right _ (by omega)
        omega
      calc n.choose i * (n - k) * (i + 1) = n.choose i * ((n - k) * (i + 1)) := by ring
        _ ≤ n.choose i * ((n - i) * k) := Nat.mul_le_mul_left _ h1
        _ = (n.choose i * (n - i)) * k := by ring
        _ = (n.choose (i + 1) * (i + 1)) * k := by rw [Nat.choose_succ_right_eq]
        _ = n.choose (i + 1) * k * (i + 1) := by ring
    exact Nat.le_of_mul_le_mul_right hmul (by omega)
  have hni : n - i = (n - i - 1) + 1 := by omega
  have hni1 : n - (i + 1) = n - i - 1 := by omega
  unfold binomTerm
  rw [hni1, hni]
  calc k ^ i * ((n - k) ^ (n - i - 1) * (n - k)) * n.choose i
      = (n.choose i * (n - k)) * (k ^ i * (n - k) ^ (n - i - 1)) := by ring
    _ ≤ (n.choose (i + 1) * k) * (k ^ i * (n - k) ^ (n - i - 1)) :=
        Nat.mul_le_mul_right _ hkey
    _ = k ^ (i + 1) * (n - k) ^ (n - i - 1) * n.choose (i + 1) := by ring

theorem binomTerm_succ_le {n k : ℕ} (hk : k ≤ n) {i : ℕ} (hi : k ≤ i) (hin : i < n) :
    binomTerm n k (i + 1) ≤ binomTerm n k i := by
  have hkey : n.choose (i + 1) * k ≤ n.choose i * (n - k) := by
    have hmul : n.choose (i + 1) * k * (i + 1) ≤ n.choose i * (n - k) * (i + 1) := by
      have h1 : (n - i) * k ≤ (n - k) * (i + 1) := by
        have ha : (n - i) * k ≤ (n - k) * k := Nat.mul_le_mul_right _ (by omega)
        have hb : (n - k) * k ≤ (n - k) * (i + 1) := Nat.mul_le_mul_left _ (by omega)
        omega
      calc n.choose (i + 1) * k * (i + 1) = (n.choose (i + 1) * (i + 1)) * k := by ring
        _ = (n.choose i * (n - i)) * k := by rw [Nat.choose_succ_right_eq]
        _ = n.choose i * ((n - i) * k) := by ring
        _ ≤ n.choose i * ((n - k) * (i + 1)) := Nat.mul_le_mul_left _ h1
        _ = n.choose i * (n - k) * (i + 1) := by ring
    exact Nat.le_of_mul_le_mul_right hmul (by omega)
  have hni : n - i = (n - i - 1) + 1 := by omega
  have hni1 : n - (i + 1) = n - i - 1 := by omega
  unfold binomTerm
  rw [hni1, hni]
  calc k ^ (i + 1) * (n - k) ^ (n - i - 1) * n.choose (i + 1)
      = (n.choose (i + 1) * k) * (k ^ i * (n - k) ^ (n - i - 1)) := by ring
    _ ≤ (n.choose i * (n - k)) * (k ^ i * (n - k) ^ (n - i - 1)) :=
        Nat.mul_le_mul_right _ hkey
    _ = k ^ i * ((n - k) ^ (n - i - 1) * (n - k)) * n.choose i := by ring

/-- Unimodality: the term at index `k` is the largest. -/
theorem binomTerm_le {n k : ℕ} (hk : k ≤ n) {i : ℕ} (hin : i ≤ n) :
    binomTerm n k i ≤ binomTerm n k k := by
  by_cases h : i ≤ k
  · have key : ∀ d : ℕ, d ≤ k → binomTerm n k (k - d) ≤ binomTerm n k k := by
      intro d
      induction d with
      | zero => intro _; simp
      | succ d ih =>
        intro hd
        have h1 : binomTerm n k (k - (d + 1)) ≤ binomTerm n k (k - (d + 1) + 1) :=
          binomTerm_le_succ hk (by omega)
        rw [show k - (d + 1) + 1 = k - d by omega] at h1
        exact le_trans h1 (ih (by omega))
    have h2 := key (k - i) (by omega)
    rwa [show k - (k - i) = i by omega] at h2
  · have key : ∀ d : ℕ, k + d ≤ n → binomTerm n k (k + d) ≤ binomTerm n k k := by
      intro d
      induction d with
      | zero => intro _; simp
      | succ d ih =>
        intro hd
        have h1 : binomTerm n k (k + d + 1) ≤ binomTerm n k (k + d) :=
          binomTerm_succ_le hk (by omega) (by omega)
        exact le_trans h1 (ih (by omega))
    have h2 := key (i - k) (by omega)
    rwa [show k + (i - k) = i by omega] at h2

/-- **Entropy lower bound for binomial coefficients.**  For every `k ≤ n`,

  `n^n ≤ (n+1) · C(n,k) · k^k · (n-k)^(n-k)`,

i.e. `C(n,k)` is within a factor `n+1` of `n^n / (k^k (n-k)^{n-k})`, the
exponential of the binary entropy of `k/n`. -/
theorem pow_self_le_succ_mul_choose_mul {n k : ℕ} (hk : k ≤ n) :
    n ^ n ≤ (n + 1) * (n.choose k * k ^ k * (n - k) ^ (n - k)) := by
  have hsum : n ^ n = ∑ m ∈ Finset.range (n + 1), binomTerm n k m := by
    have h := add_pow k (n - k) n
    rw [show k + (n - k) = n by omega] at h
    rw [h]; rfl
  rw [hsum]
  have hbd : ∀ m ∈ Finset.range (n + 1), binomTerm n k m ≤ binomTerm n k k := by
    intro m hm
    exact binomTerm_le hk (by simp at hm; omega)
  have hs := Finset.sum_le_card_nsmul (Finset.range (n + 1)) (binomTerm n k)
    (binomTerm n k k) hbd
  simp only [Finset.card_range, smul_eq_mul] at hs
  have hTk : binomTerm n k k = n.choose k * k ^ k * (n - k) ^ (n - k) := by
    unfold binomTerm; ring
  rwa [hTk] at hs

/-! ### The asymmetric entropy base -/

/-- The asymmetric Ramsey entropy base: the unique `β` with
`β^(s+t) = (s+t)^(s+t) / (s^s t^t)`, i.e. `2^{H(s/(s+t))}`. -/
noncomputable def ramseyEntropyBase (s t : ℕ) : ℝ :=
  ((((s + t : ℕ) : ℝ) ^ (s + t)) / ((s : ℝ) ^ s * (t : ℝ) ^ t)) ^ (((s + t : ℕ) : ℝ))⁻¹

theorem ramseyEntropyBase_pow {s t : ℕ} (hs : 0 < s) (ht : 0 < t) :
    (ramseyEntropyBase s t) ^ (s + t) =
      (((s + t : ℕ) : ℝ) ^ (s + t)) / ((s : ℝ) ^ s * (t : ℝ) ^ t) := by
  have hsR : (0 : ℝ) < (s : ℝ) := by exact_mod_cast hs
  have htR : (0 : ℝ) < (t : ℝ) := by exact_mod_cast ht
  have hden : (0 : ℝ) < (s : ℝ) ^ s * (t : ℝ) ^ t := by positivity
  have hnum : (0 : ℝ) ≤ (((s + t : ℕ) : ℝ) ^ (s + t)) := by positivity
  refine Real.rpow_inv_natCast_pow (by positivity) ?_
  omega

/-! ### FD3: no proportional saving against the entropy base -/

/-- **FD3.**  On any parameter set consisting of pairs of positive integers and
containing pairs of arbitrarily large total size, the binomial coefficient
admits no proportional saving against the entropy base. -/
theorem not_hasProportionalSaving₂_choose {S : Set (ℕ × ℕ)}
    (hpos : ∀ p ∈ S, 0 < p.1 ∧ 0 < p.2)
    (hunb : ∀ N : ℕ, ∃ p ∈ S, N ≤ p.1 + p.2) :
    ¬ HasProportionalSaving₂ (fun s t => (s + t).choose s) ramseyEntropyBase S := by
  rintro ⟨q, hq0, hq1, hbd⟩
  -- `(n+1) q^n → 0`, so pick a threshold `N` beyond which it is `< 1`
  have htend : Filter.Tendsto (fun n : ℕ => (n : ℝ) * q ^ n) Filter.atTop (nhds 0) :=
    tendsto_self_mul_const_pow_of_lt_one hq0.le hq1
  have htend2 : Filter.Tendsto (fun n : ℕ => ((n : ℝ) + 1) * q ^ n) Filter.atTop
      (nhds 0) := by
    have h2 : Filter.Tendsto (fun n : ℕ => q ^ n) Filter.atTop (nhds 0) :=
      tendsto_pow_atTop_nhds_zero_of_lt_one hq0.le hq1
    have := htend.add h2
    simpa [add_mul] using this
  have hev : ∀ᶠ n : ℕ in Filter.atTop, ((n : ℝ) + 1) * q ^ n < 1 := by
    have := htend2.eventually (eventually_lt_nhds (by norm_num : (0 : ℝ) < 1))
    exact this
  obtain ⟨N, hN⟩ := Filter.eventually_atTop.mp hev
  obtain ⟨p, hpS, hpN⟩ := hunb N
  obtain ⟨hs, ht⟩ := hpos p hpS
  set s := p.1 with hsdef
  set t := p.2 with htdef
  set n := s + t with hndef
  have hsR : (0 : ℝ) < (s : ℝ) := by exact_mod_cast hs
  have htR : (0 : ℝ) < (t : ℝ) := by exact_mod_cast ht
  have hden : (0 : ℝ) < (s : ℝ) ^ s * (t : ℝ) ^ t := by positivity
  have hnR : (0 : ℝ) < (n : ℝ) := by
    have : 0 < n := by omega
    exact_mod_cast this
  -- the assumed proportional saving
  have hb := hbd p hpS
  rw [mul_pow, ramseyEntropyBase_pow hs ht] at hb
  -- the entropy lower bound
  have hlow : (n : ℕ) ^ n ≤ (n + 1) * (n.choose s * s ^ s * (n - s) ^ (n - s)) :=
    pow_self_le_succ_mul_choose_mul (by omega)
  rw [show n - s = t by omega] at hlow
  have hlowR : ((n : ℝ)) ^ n ≤ ((n : ℝ) + 1) *
      (((n.choose s : ℕ) : ℝ) * (s : ℝ) ^ s * (t : ℝ) ^ t) := by
    exact_mod_cast hlow
  -- combine
  have hb' : ((n.choose s : ℕ) : ℝ) * ((s : ℝ) ^ s * (t : ℝ) ^ t) ≤
      q ^ n * ((n : ℝ) ^ n) := by
    have := mul_le_mul_of_nonneg_right hb hden.le
    calc ((n.choose s : ℕ) : ℝ) * ((s : ℝ) ^ s * (t : ℝ) ^ t)
        ≤ (q ^ n * (((n : ℕ) : ℝ) ^ n / ((s : ℝ) ^ s * (t : ℝ) ^ t))) *
            ((s : ℝ) ^ s * (t : ℝ) ^ t) := this
      _ = q ^ n * ((n : ℝ) ^ n) := by field_simp
  have hchain : ((n : ℝ)) ^ n ≤ ((n : ℝ) + 1) * (q ^ n * ((n : ℝ) ^ n)) := by
    refine le_trans hlowR ?_
    have hnn : (0 : ℝ) ≤ (n : ℝ) + 1 := by positivity
    refine mul_le_mul_of_nonneg_left ?_ hnn
    calc ((n.choose s : ℕ) : ℝ) * (s : ℝ) ^ s * (t : ℝ) ^ t
        = ((n.choose s : ℕ) : ℝ) * ((s : ℝ) ^ s * (t : ℝ) ^ t) := by ring
      _ ≤ q ^ n * ((n : ℝ) ^ n) := hb'
  have hnn : (0 : ℝ) < (n : ℝ) ^ n := by positivity
  have hone : (1 : ℝ) ≤ ((n : ℝ) + 1) * q ^ n := by
    have h := hchain
    rw [show ((n : ℝ) + 1) * (q ^ n * ((n : ℝ) ^ n)) =
      (((n : ℝ) + 1) * q ^ n) * ((n : ℝ) ^ n) by ring] at h
    nlinarith
  have hlt := hN n (by omega)
  linarith

/-! ### Ratio windows -/

/-- The ratio window `[a,b]`: pairs `(s,t)` of positive integers whose ratio
`s/(s+t)` lies in `[a,b]`. -/
def ratioWindow (a b : ℝ) : Set (ℕ × ℕ) :=
  {p | 0 < p.1 ∧ 0 < p.2 ∧
    a ≤ (p.1 : ℝ) / ((p.1 + p.2 : ℕ) : ℝ) ∧ (p.1 : ℝ) / ((p.1 + p.2 : ℕ) : ℝ) ≤ b}

/-- A nondegenerate window contains pairs of arbitrarily large total size. -/
theorem ratioWindow_unbounded {a b : ℝ} (ha : 0 < a) (hab : a < b) (hb : b < 1)
    (N : ℕ) : ∃ p ∈ ratioWindow a b, N ≤ p.1 + p.2 := by
  obtain ⟨m, hm⟩ := exists_nat_gt (max (1 / (b - a)) (1 / (1 - a)))
  set n : ℕ := max (max N 1) m with hn
  have hnm : (m : ℝ) ≤ (n : ℝ) := by exact_mod_cast le_max_right _ _
  have hn1 : 1 ≤ n := le_trans (le_max_right N 1) (le_max_left _ _)
  have hnN : N ≤ n := le_trans (le_max_left _ _) (le_max_left _ _)
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn1
  have hba : 1 / (b - a) < (n : ℝ) :=
    lt_of_le_of_lt (le_max_left _ _) (lt_of_lt_of_le hm hnm)
  have h1a : 1 / (1 - a) < (n : ℝ) :=
    lt_of_le_of_lt (le_max_right _ _) (lt_of_lt_of_le hm hnm)
  have hba' : 1 < (b - a) * (n : ℝ) := by
    rw [div_lt_iff₀ (by linarith)] at hba; linarith
  have h1a' : 1 < (1 - a) * (n : ℝ) := by
    rw [div_lt_iff₀ (by linarith)] at h1a; linarith
  set s : ℕ := ⌈a * (n : ℝ)⌉₊ with hs
  have han : (0 : ℝ) < a * (n : ℝ) := by positivity
  have hs1 : 1 ≤ s := Nat.one_le_iff_ne_zero.mpr (by
    simp only [hs, ne_eq, Nat.ceil_eq_zero, not_le]
    exact han)
  have hsle : a * (n : ℝ) ≤ (s : ℝ) := Nat.le_ceil _
  have hslt : (s : ℝ) < a * (n : ℝ) + 1 := Nat.ceil_lt_add_one han.le
  have hsn : s < n := by
    have h : (s : ℝ) < (n : ℝ) := by nlinarith
    exact_mod_cast h
  have hsum : s + (n - s) = n := by omega
  refine ⟨(s, n - s), ⟨hs1, by omega, ?_, ?_⟩, by omega⟩
  · show a ≤ (s : ℝ) / ((s + (n - s) : ℕ) : ℝ)
    rw [hsum, le_div_iff₀ hnR]
    linarith
  · show (s : ℝ) / ((s + (n - s) : ℕ) : ℝ) ≤ b
    rw [hsum, div_le_iff₀ hnR]
    nlinarith

/-- **FD3 for ratio windows.**  For every nondegenerate window `[a,b] ⊆ (0,1)`
the binomial coefficient `C(s+t,s)` admits no proportional saving against the
entropy base: the Erdős–Szekeres estimate is tight up to the factor `s+t+1`
uniformly on the window. -/
theorem not_hasProportionalSaving₂_choose_ratioWindow {a b : ℝ}
    (ha : 0 < a) (hab : a < b) (hb : b < 1) :
    ¬ HasProportionalSaving₂ (fun s t => (s + t).choose s) ramseyEntropyBase
      (ratioWindow a b) :=
  not_hasProportionalSaving₂_choose
    (fun _ hp => ⟨hp.1, hp.2.1⟩)
    (ratioWindow_unbounded ha hab hb)

/-- **Necessity of nondegeneracy.**  FD3 as literally stated ("for every window
`[a,b] ⊆ (0,1)`") is false without a nonemptiness/unboundedness hypothesis: for
`b < a` the window is empty and the proportional saving holds vacuously. -/
theorem hasProportionalSaving₂_choose_of_degenerate_window {a b : ℝ}
    (hba : b < a) :
    HasProportionalSaving₂ (fun s t => (s + t).choose s) ramseyEntropyBase
      (ratioWindow a b) := by
  refine ⟨1 / 2, by norm_num, by norm_num, ?_⟩
  intro p hp
  exact absurd (le_trans hp.2.2.1 hp.2.2.2) (not_le.mpr hba)

end RamseyBounds