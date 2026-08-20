/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Applications.InvisibleWeightsL1

/-!
# Invisibility is multiplicative: composing weight vectors

`Applications/InvisibleWeightsL1.lean` refutes the conjecture `ℓ¹ ≥ 2^K` by exhibiting one
cheap witness at `K = 3` and propagating it with the difference operator, at a cost of a
factor `2` per unit of window.  That propagation is wasteful.  This file replaces it by the
correct structural statement: **windows add and `ℓ¹` norms multiply under convolution**, so a
*single* economical witness improves the bound in *every* degree by an exponential factor.

## Main results

* `shiftBy`, `moment_shiftBy` — translating a weight vector by `a` transforms its moments by
  the binomial law `m_k(shift_a e) = ∑_{t ≤ k} C(k,t) · a^{k-t} · m_t(e)`.
* `kconv M w e` — the convolution of a kernel `w` supported on `{0,…,M}` with `e`; on
  generating polynomials this is multiplication of polynomials.
* `moment_kconv` — **the composition law for moments:**
  `m_k(w * e) = ∑_{t ≤ k} C(k,t) · m_t(e) · m_{k-t}(w)`.
* `kconv_invisible` — **windows add:** invisible at window `K_w` convolved with invisible at
  window `K_e` is invisible at window `K_w + K_e`.
* `moment_kconv_top` — the first visible moment of the convolution is
  `C(K_w + K_e, K_e) · m_{K_e}(e) · m_{K_w}(w)`, so nondegeneracy is preserved.
* `l1_kconv_le` — **`ℓ¹` norms multiply:** `ℓ¹(w * e) ≤ ℓ¹(w) · ℓ¹(e)`.
* `exists_invisible_l1_le_six_pow` — iterating the composition law with the `K = 3` witness of
  `ℓ¹ = 6` gives, at every window `K = 3n`, a nonzero invisible vector with `ℓ¹ ≤ 6^n`.
* `l1_exponentially_below_two_pow` — the quantitative form: at window `K = 3n` there are
  invisible vectors with `4^n · ℓ¹ ≤ 3^n · 2^K`, i.e. `ℓ¹ ≤ (3/4)^n · 2^K`.  The binomial
  vector is not merely non-optimal, it is off by an exponential factor.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).  Invisibility at window `K` is divisibility of the generating
polynomial by `(X-1)^K`, and `ℓ¹` of a coefficient vector is submultiplicative under
polynomial multiplication.  So the function `L(K) =` minimal `ℓ¹` at window `K` should be
*submultiplicative*: `L(K₁ + K₂) ≤ L(K₁) · L(K₂)`.  Bold consequence: since `L(3) ≤ 6 < 8`,
Fekete-type reasoning forces `L(K) ≤ 6^{K/3} ≈ 1.817^K`, exponentially below the binomial
value `2^K`.

EXPERIMENT (Experimenter).  Both halves formalised below without polynomials, directly on
weight vectors: the moment composition law `moment_kconv` (windows add) and the triangle
inequality `l1_kconv_le` (norms multiply).  Instantiating with the witness
`pteWitness = (-1, 2, 0, -2, 1)` gives `ℓ¹ ≤ 6^n` at window `3n` against `2^{3n} = 8^n`.
Sample data (`#eval` on the definitions below): two convolutions of the witness produce the
vector `[1, -4, 4, 4, -10, 4, 4, -4, 1]` on the nodes `{0,…,8}`, whose moments are
`0, 0, 0, 0, 0, 0, 2880, 80640` — invisible exactly to the window `k < 6`, with `ℓ¹ = 36 = 6²`
against `2^6 = 64`, and with first visible moment `2880 = C(6,3) · 12 · 12`, as predicted by
`moment_kconv_top`.  Comparing the two propagation bounds: at `K = 6`, the difference operator
gives `6 · 2^3 = 48` against the composition bound `36`; at `K = 12`, `3072` against `1296`;
at `K = 30`, `805 306 368` against `6^10 = 60 466 176`, with `2^30 = 1 073 741 824`.

ANALYSIS (Analyst).  The refutation of `2^K` is therefore not a small numerical accident at
`K = 3` but a structural fact: the minimal-`ℓ¹` function is submultiplicative, so *any* single
witness below `2^K` forces an exponential gap in all large windows.  What the method cannot
reach is the truth: submultiplicativity gives `L(K) ≤ C^K` with `C = 6^{1/3}`, while the
conjectured truth `L(K) = 2K` is polynomial.  Passing from exponential to polynomial requires
witnesses whose *ratio* `L(K)/L(K-1) → 1`, i.e. ideal Prouhet–Tarry–Escott solutions; that is
Conjecture 1 of `FUTURE_DIRECTIONS.md`.

CRITIQUE (Critic).  Every bound is guarded by explicit support hypotheses (`hsupp`), without
which the reindexing of translated vectors silently loses mass beyond the node window; the
nondegeneracy of the constructed witnesses is not asserted abstractly but propagated
quantitatively through `moment_kconv_top`, so no statement here is vacuous.
-/

open Finset

namespace InvisibleWeights

/-! ### Translation -/

/-- `shiftBy a e` translates the weight vector `e` by `a` nodes to the right. -/
def shiftBy (a : ℕ) (e : ℕ → ℤ) : ℕ → ℤ := fun j => if a ≤ j then e (j - a) else 0

lemma abs_shiftBy (a : ℕ) (e : ℕ → ℤ) (j : ℕ) :
    |shiftBy a e j| = shiftBy a (fun i => |e i|) j := by
  by_cases h : a ≤ j <;> simp [shiftBy, h]

/-- **Binomial transformation law of the moments under translation.** -/
lemma moment_shiftBy {N M a : ℕ} {e : ℕ → ℤ} (hsupp : ∀ j, N < j → e j = 0) (hM : N + a ≤ M)
    (k : ℕ) :
    moment M (shiftBy a e) k
      = ∑ t ∈ range (k + 1), (k.choose t : ℤ) * (a : ℤ) ^ (k - t) * moment N e t := by
  have ha : a ≤ M + 1 := by omega
  have h1 : moment M (shiftBy a e) k
      = ∑ i ∈ range (M + 1 - a), e i * ((a : ℤ) + (i : ℤ)) ^ k := by
    have hIco : ∑ j ∈ range (M + 1), shiftBy a e j * (j : ℤ) ^ k
        = ∑ j ∈ Finset.Ico 0 (M + 1), shiftBy a e j * (j : ℤ) ^ k := by
      rw [Finset.range_eq_Ico]
    have hlow : ∑ j ∈ Finset.Ico 0 a, shiftBy a e j * (j : ℤ) ^ k = 0 := by
      refine Finset.sum_eq_zero fun j hj => ?_
      have hja : j < a := (Finset.mem_Ico.mp hj).2
      simp [shiftBy, Nat.not_le.mpr hja]
    rw [moment, hIco, ← Finset.sum_Ico_consecutive _ (Nat.zero_le a) ha, hlow, zero_add,
      Finset.sum_Ico_eq_sum_range]
    refine Finset.sum_congr rfl fun i _ => ?_
    have hai : a ≤ a + i := Nat.le_add_right _ _
    simp only [shiftBy, if_pos hai, Nat.add_sub_cancel_left]
    push_cast
    ring
  have h2 : ∑ i ∈ range (M + 1 - a), e i * ((a : ℤ) + (i : ℤ)) ^ k
      = ∑ i ∈ range (N + 1), e i * ((a : ℤ) + (i : ℤ)) ^ k := by
    refine (Finset.sum_subset (by intro x hx; simp only [mem_range] at *; omega) ?_).symm
    intro x _ hx
    rw [hsupp x (by simp only [mem_range] at hx; omega), zero_mul]
  rw [h1, h2]
  have hexp : ∀ i : ℕ, ((a : ℤ) + (i : ℤ)) ^ k
      = ∑ t ∈ range (k + 1), (k.choose t : ℤ) * (a : ℤ) ^ (k - t) * (i : ℤ) ^ t := by
    intro i
    rw [add_comm, add_pow]
    exact Finset.sum_congr rfl fun t _ => by ring
  calc ∑ i ∈ range (N + 1), e i * ((a : ℤ) + (i : ℤ)) ^ k
      = ∑ i ∈ range (N + 1), ∑ t ∈ range (k + 1),
          ((k.choose t : ℤ) * (a : ℤ) ^ (k - t)) * (e i * (i : ℤ) ^ t) := by
        refine Finset.sum_congr rfl fun i _ => ?_
        rw [hexp i, Finset.mul_sum]
        exact Finset.sum_congr rfl fun t _ => by ring
    _ = ∑ t ∈ range (k + 1), (k.choose t : ℤ) * (a : ℤ) ^ (k - t) * moment N e t := by
        rw [Finset.sum_comm]
        refine Finset.sum_congr rfl fun t _ => ?_
        rw [moment, Finset.mul_sum]

/-- The zeroth moment is the plain sum of the entries. -/
lemma moment_zero_eq_sum (N : ℕ) (e : ℕ → ℤ) : moment N e 0 = ∑ j ∈ range (N + 1), e j := by
  simp [moment]

/-- Translation preserves the total mass of a supported vector. -/
lemma sum_shiftBy {N M a : ℕ} {e : ℕ → ℤ} (hsupp : ∀ j, N < j → e j = 0) (hM : N + a ≤ M) :
    ∑ j ∈ range (M + 1), shiftBy a e j = ∑ i ∈ range (N + 1), e i := by
  have h := moment_shiftBy hsupp hM 0
  simpa [moment_zero_eq_sum] using h

/-! ### Convolution with a kernel -/

/-- `kconv M w e` is the convolution of the kernel `w`, supported on `{0,…,M}`, with `e`.
On generating polynomials this is the product of polynomials. -/
def kconv (M : ℕ) (w e : ℕ → ℤ) : ℕ → ℤ := fun j => ∑ a ∈ range (M + 1), w a * shiftBy a e j

lemma moment_finset_sum {ι : Type*} (N : ℕ) (s : Finset ι) (f : ι → ℕ → ℤ) (k : ℕ) :
    moment N (fun j => ∑ a ∈ s, f a j) k = ∑ a ∈ s, moment N (f a) k := by
  simp only [moment, Finset.sum_mul]
  exact Finset.sum_comm

lemma kconv_of_gt {N M : ℕ} {w e : ℕ → ℤ} (hsupp : ∀ j, N < j → e j = 0) :
    ∀ j, N + M < j → kconv M w e j = 0 := by
  intro j hj
  refine Finset.sum_eq_zero fun a ha => ?_
  have haM : a ≤ M := Nat.lt_succ_iff.mp (mem_range.mp ha)
  by_cases h : a ≤ j
  · simp only [shiftBy, if_pos h]
    rw [hsupp (j - a) (by omega), mul_zero]
  · simp [shiftBy, h]

/-- **The composition law for moments.** -/
theorem moment_kconv {N M : ℕ} {w e : ℕ → ℤ} (hsupp : ∀ j, N < j → e j = 0) (k : ℕ) :
    moment (N + M) (kconv M w e) k
      = ∑ t ∈ range (k + 1), (k.choose t : ℤ) * moment N e t * moment M w (k - t) := by
  have hdef : moment (N + M) (kconv M w e) k
      = moment (N + M) (fun j => ∑ a ∈ range (M + 1), w a * shiftBy a e j) k := rfl
  rw [hdef, moment_finset_sum]
  have hterm : ∀ a ∈ range (M + 1),
      moment (N + M) (fun j => w a * shiftBy a e j) k
        = ∑ t ∈ range (k + 1), (k.choose t : ℤ) * moment N e t * (w a * (a : ℤ) ^ (k - t)) := by
    intro a ha
    have haM : a ≤ M := Nat.lt_succ_iff.mp (mem_range.mp ha)
    have hlin : moment (N + M) (fun j => w a * shiftBy a e j) k
        = w a * moment (N + M) (shiftBy a e) k := by
      rw [moment, moment, Finset.mul_sum]
      exact Finset.sum_congr rfl fun j _ => by ring
    rw [hlin, moment_shiftBy hsupp (by omega : N + a ≤ N + M) k, Finset.mul_sum]
    exact Finset.sum_congr rfl fun t _ => by ring
  rw [Finset.sum_congr rfl hterm, Finset.sum_comm]
  refine Finset.sum_congr rfl fun t _ => ?_
  have hpull : ∑ a ∈ range (M + 1), ((k.choose t : ℤ) * moment N e t) * (w a * (a : ℤ) ^ (k - t))
      = ((k.choose t : ℤ) * moment N e t) * ∑ a ∈ range (M + 1), w a * (a : ℤ) ^ (k - t) :=
    (Finset.mul_sum _ _ _).symm
  exact hpull

/-- **Windows add under convolution.** -/
theorem kconv_invisible {N M Ke Kw : ℕ} {w e : ℕ → ℤ} (hsupp : ∀ j, N < j → e j = 0)
    (he : Invisible N Ke e) (hw : Invisible M Kw w) :
    Invisible (N + M) (Ke + Kw) (kconv M w e) := by
  intro k hk
  rw [moment_kconv hsupp]
  refine Finset.sum_eq_zero fun t ht => ?_
  have htk : t ≤ k := Nat.lt_succ_iff.mp (mem_range.mp ht)
  by_cases hcase : t < Ke
  · rw [he t hcase, mul_zero, zero_mul]
  · rw [hw (k - t) (by omega), mul_zero]

/-- The first visible moment of a convolution. -/
theorem moment_kconv_top {N M Ke Kw : ℕ} {w e : ℕ → ℤ} (hsupp : ∀ j, N < j → e j = 0)
    (he : Invisible N Ke e) (hw : Invisible M Kw w) :
    moment (N + M) (kconv M w e) (Ke + Kw)
      = ((Ke + Kw).choose Ke : ℤ) * moment N e Ke * moment M w Kw := by
  rw [moment_kconv hsupp]
  have hsingle : ∀ t ∈ range (Ke + Kw + 1), t ≠ Ke →
      (((Ke + Kw).choose t : ℤ) * moment N e t * moment M w (Ke + Kw - t)) = 0 := by
    intro t ht hne
    have htk : t ≤ Ke + Kw := Nat.lt_succ_iff.mp (mem_range.mp ht)
    rcases lt_or_gt_of_ne hne with h | h
    · rw [he t h, mul_zero, zero_mul]
    · rw [hw (Ke + Kw - t) (by omega), mul_zero]
  rw [Finset.sum_eq_single_of_mem Ke (mem_range.mpr (by omega)) hsingle]
  rw [Nat.add_sub_cancel_left]

/-- **`ℓ¹` norms multiply under convolution.** -/
theorem l1_kconv_le {N M : ℕ} {w e : ℕ → ℤ} (hsupp : ∀ j, N < j → e j = 0) :
    ∑ j ∈ range (N + M + 1), |kconv M w e j|
      ≤ (∑ a ∈ range (M + 1), |w a|) * ∑ i ∈ range (N + 1), |e i| := by
  have habs : ∀ j, |kconv M w e j| ≤ ∑ a ∈ range (M + 1), |w a| * shiftBy a (fun i => |e i|) j := by
    intro j
    refine (Finset.abs_sum_le_sum_abs _ _).trans (le_of_eq ?_)
    refine Finset.sum_congr rfl fun a _ => ?_
    rw [abs_mul, abs_shiftBy]
  refine (Finset.sum_le_sum fun j _ => habs j).trans (le_of_eq ?_)
  rw [Finset.sum_comm, Finset.sum_mul]
  refine Finset.sum_congr rfl fun a ha => ?_
  have haM : a ≤ M := Nat.lt_succ_iff.mp (mem_range.mp ha)
  have habs_supp : ∀ j, N < j → |e j| = 0 := fun j hj => by rw [hsupp j hj, abs_zero]
  rw [← Finset.mul_sum, sum_shiftBy habs_supp (by omega : N + a ≤ N + M)]

/-! ### Iterating the cheap witness -/

/-- **Exponential improvement.**  At every window `K = 3n` there is a nonzero integral vector
invisible to the window with `ℓ¹ ≤ 6^n`, obtained by convolving `n` copies of the `K = 3`
witness `(-1, 2, 0, -2, 1)`. -/
theorem exists_invisible_l1_le_six_pow (n : ℕ) :
    ∃ (N : ℕ) (e : ℕ → ℤ), (∀ j, N < j → e j = 0) ∧ Invisible N (3 * n) e ∧
      moment N e (3 * n) ≠ 0 ∧ ∑ j ∈ range (N + 1), |e j| ≤ 6 ^ n := by
  induction n with
  | zero =>
      refine ⟨0, fun j => if j = 0 then 1 else 0, ?_, ?_, ?_, ?_⟩
      · intro j hj
        show (if j = 0 then (1 : ℤ) else 0) = 0
        rw [if_neg (by omega)]
      · intro k hk
        omega
      · simp [moment]
      · simp
  | succ n ih =>
      obtain ⟨N, e, hsupp, hinv, htop, hl1⟩ := ih
      refine ⟨N + 4, kconv 4 pteWitness e, kconv_of_gt hsupp, ?_, ?_, ?_⟩
      · have h := kconv_invisible hsupp hinv pteWitness_invisible
        rwa [show 3 * n + 3 = 3 * (n + 1) by ring] at h
      · have h := moment_kconv_top hsupp hinv pteWitness_invisible
        rw [show 3 * (n + 1) = 3 * n + 3 by ring]
        rw [h, pteWitness_moment_top]
        refine mul_ne_zero (mul_ne_zero ?_ htop) (by norm_num)
        exact_mod_cast Nat.choose_pos (by omega) |>.ne'
      · have h := l1_kconv_le (M := 4) (w := pteWitness) hsupp
        have hw : ∑ a ∈ range 5, |pteWitness a| = 6 := pteWitness_l1
        rw [hw] at h
        calc ∑ j ∈ range (N + 4 + 1), |kconv 4 pteWitness e j|
            ≤ 6 * ∑ i ∈ range (N + 1), |e i| := h
          _ ≤ 6 * 6 ^ n := by omega
          _ = 6 ^ (n + 1) := by ring

/-- **The binomial vector is off by an exponential factor.**  At window `K = 3n` there are
nonzero invisible vectors with `4^n · ℓ¹ ≤ 3^n · 2^K`, i.e. `ℓ¹ ≤ (3/4)^n · 2^K`. -/
theorem l1_exponentially_below_two_pow (n : ℕ) :
    ∃ (N : ℕ) (e : ℕ → ℤ), Invisible N (3 * n) e ∧ (∃ j ≤ N, e j ≠ 0) ∧
      4 ^ n * ∑ j ∈ range (N + 1), |e j| ≤ 3 ^ n * 2 ^ (3 * n) := by
  obtain ⟨N, e, hsupp, hinv, htop, hl1⟩ := exists_invisible_l1_le_six_pow n
  refine ⟨N, e, hinv, ?_, ?_⟩
  · by_contra hcon
    push_neg at hcon
    apply htop
    refine Finset.sum_eq_zero fun j hj => ?_
    rw [hcon j (Nat.lt_succ_iff.mp (mem_range.mp hj)), zero_mul]
  · have hpow : (4 : ℤ) ^ n * 6 ^ n = 3 ^ n * 2 ^ (3 * n) := by
      rw [pow_mul, ← mul_pow, ← mul_pow]
      norm_num
    calc (4 : ℤ) ^ n * ∑ j ∈ range (N + 1), |e j|
        ≤ 4 ^ n * 6 ^ n := by
          exact mul_le_mul_of_nonneg_left hl1 (by positivity)
      _ = 3 ^ n * 2 ^ (3 * n) := hpow

end InvisibleWeights