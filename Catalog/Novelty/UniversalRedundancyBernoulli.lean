/-
# The price of universality, IV: a Rissanen-style `(1/2) log₂ n` lower bound

We instantiate the exact minimax theory of `UniversalRedundancyShtarkov` on the
class of **memoryless binary sources of block length `n`**: messages are binary
strings of length `n` (encoded as subsets of `Fin n`), and the source with
parameter `t` gives the string `s` probability `t ^ #s * (1 - t) ^ (n - #s)`.
The class is indexed by the maximum-likelihood grid `t = j / n`, `j = 0, …, n`
(the standard parametrisation for normalised maximum likelihood: `j/n` is exactly
the MLE of a string with `j` ones).

The main theorem, `bernoulli_regret_ge_half_logb`, states that **every** code for
length-`n` binary strings suffers, on some string, a regret of at least

  `(1/2) · log₂ n − 2`  bits

against the best member of the class.  This reproduces Rissanen's `(k/2) log n`
minimax redundancy rate for a `k = 1`-parameter family, with explicit constants
and no asymptotics.

The proof is the classical "counting distinguishable sources" argument made
quantitative:

* the Shtarkov sum dominates `∑ᵢ Pθᵢ(Kᵢ)` for any disjoint family of index sets;
* Chebyshev's inequality (`binw_concentration`) shows that a binomial source
  with mean `c` puts mass `≥ 3/4` on the window of half-width `d ≈ √n` around `c`;
* there are `≈ √n / 2` such windows inside `[0, n]`, so the Shtarkov sum is
  `≥ √n / 4`, i.e. the class contains `≈ √n` mutually distinguishable sources.
-/
import Novelty.UniversalRedundancyShtarkov
import Novelty.BinomialConcentration

namespace PriceOfUniversality

open Finset Real

/-! ## The class of memoryless binary sources -/

/-- Messages of block length `n`: binary strings, encoded as subsets of `Fin n`
(the set of positions carrying a one). -/
abbrev Msg (n : ℕ) := Finset (Fin n)

/-- The memoryless (i.i.d. Bernoulli) source with parameter `t` on strings of
length `n`. -/
noncomputable def bern (n : ℕ) (t : ℝ) (s : Msg n) : ℝ := t ^ (#s) * (1 - t) ^ (n - #s)

/-- The class of memoryless binary sources indexed by the maximum-likelihood grid
`t = j / n`. -/
noncomputable def bernClass (n : ℕ) : Fin (n + 1) → Msg n → ℝ :=
  fun j s => bern n ((j : ℝ) / n) s

/-- Summing a function of the number of ones over all binary strings of length `n`
is summing against binomial coefficients. -/
lemma sum_over_msgs (n : ℕ) (g : ℕ → ℝ) :
    ∑ s : Msg n, g (#s) = ∑ k ∈ range (n + 1), (n.choose k : ℝ) * g k := by
  have h1 : (univ : Finset (Finset (Fin n))) = (univ : Finset (Fin n)).powerset := by
    simp
  rw [h1, Finset.sum_powerset]
  simp only [Finset.card_univ, Fintype.card_fin]
  refine Finset.sum_congr rfl fun j _ => ?_
  rw [Finset.sum_powersetCard]
  simp [Finset.card_univ, nsmul_eq_mul]

lemma bern_eq_binw (n : ℕ) (t : ℝ) (k : ℕ) :
    (n.choose k : ℝ) * (t ^ k * (1 - t) ^ (n - k)) = binw n t k := rfl

/-- Each member of the class is a probability distribution on strings. -/
theorem bern_isPMF {n : ℕ} {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) : IsPMF (bern n t) := by
  have h1t : 0 ≤ 1 - t := by linarith
  refine ⟨fun s => by unfold bern; positivity, ?_⟩
  calc ∑ s : Msg n, bern n t s
      = ∑ k ∈ range (n + 1), (n.choose k : ℝ) * (t ^ k * (1 - t) ^ (n - k)) :=
        sum_over_msgs n (fun k => t ^ k * (1 - t) ^ (n - k))
    _ = ∑ k ∈ range (n + 1), binw n t k :=
        Finset.sum_congr rfl fun k _ => bern_eq_binw n t k
    _ = 1 := binw_sum n t

lemma grid_mem_Icc {n : ℕ} (j : Fin (n + 1)) : 0 ≤ (j : ℝ) / n ∧ (j : ℝ) / n ≤ 1 := by
  rcases Nat.eq_zero_or_pos n with hn | hn
  · subst hn
    simp
  · have hnR : (0:ℝ) < n := by exact_mod_cast hn
    have hj : (j : ℝ) ≤ n := by
      have : (j : ℕ) ≤ n := Nat.lt_succ_iff.mp j.isLt
      exact_mod_cast this
    constructor
    · positivity
    · rw [div_le_one hnR]; exact hj

theorem bernClass_isPMF (n : ℕ) (j : Fin (n + 1)) : IsPMF (bernClass n j) :=
  bern_isPMF (grid_mem_Icc j).1 (grid_mem_Icc j).2

/-! ## The Shtarkov sum of the class -/

/-- The maximum likelihood of a string with `k` ones, over the grid. -/
noncomputable def mlik (n : ℕ) (k : ℕ) : ℝ :=
  (univ : Finset (Fin (n + 1))).sup' univ_nonempty
    (fun j => ((j : ℝ) / n) ^ k * (1 - (j : ℝ) / n) ^ (n - k))

lemma maxLik_bernClass (n : ℕ) (s : Msg n) : maxLik (bernClass n) s = mlik n (#s) := rfl

lemma mlik_nonneg (n k : ℕ) : 0 ≤ mlik n k := by
  have h0 : (0:ℝ) ≤ ((0 : Fin (n + 1)) : ℝ) / n ^ k * (1 - ((0 : Fin (n + 1)) : ℝ) / n) ^ (n - k) := by
    simp
  refine le_trans ?_ (Finset.le_sup' (α := ℝ)
    (fun j : Fin (n + 1) => ((j : ℝ) / n) ^ k * (1 - (j : ℝ) / n) ^ (n - k))
    (mem_univ (0 : Fin (n + 1))))
  have : ((0 : Fin (n + 1)) : ℝ) = 0 := by simp
  rw [this]
  rcases Nat.eq_zero_or_pos k with hk | hk
  · subst hk; norm_num
  · rw [zero_div, zero_pow (by omega)]
    simp

lemma binw_le_choose_mul_mlik (n : ℕ) (j : Fin (n + 1)) (k : ℕ) :
    binw n ((j : ℝ) / n) k ≤ (n.choose k : ℝ) * mlik n k := by
  rw [← bern_eq_binw]
  refine mul_le_mul_of_nonneg_left ?_ (by positivity)
  exact Finset.le_sup' (α := ℝ)
    (fun j : Fin (n + 1) => ((j : ℝ) / n) ^ k * (1 - (j : ℝ) / n) ^ (n - k)) (mem_univ j)

/-- The Shtarkov sum of the class, expressed as a sum over the number of ones. -/
theorem shtarkov_bernClass (n : ℕ) :
    shtarkov (bernClass n) = ∑ k ∈ range (n + 1), (n.choose k : ℝ) * mlik n k := by
  rw [shtarkov]
  calc ∑ s : Msg n, maxLik (bernClass n) s = ∑ s : Msg n, mlik n (#s) :=
        Finset.sum_congr rfl fun s _ => maxLik_bernClass n s
    _ = ∑ k ∈ range (n + 1), (n.choose k : ℝ) * mlik n k := sum_over_msgs n (mlik n)

/-- **Distinguishable sources force a large Shtarkov sum.** For any finite family of
pairwise disjoint sets of "number of ones", and any choice of a grid parameter for
each, the total mass captured is a lower bound for the Shtarkov sum. -/
theorem sum_windows_le_shtarkov (n : ℕ) (I : Finset ℕ) (K : ℕ → Finset ℕ)
    (hK : ∀ i ∈ I, K i ⊆ range (n + 1))
    (hdisj : (I : Set ℕ).PairwiseDisjoint K) (jsel : ℕ → Fin (n + 1)) :
    ∑ i ∈ I, ∑ k ∈ K i, binw n ((jsel i : ℝ) / n) k ≤ shtarkov (bernClass n) := by
  have hstep : ∀ i ∈ I, ∑ k ∈ K i, binw n ((jsel i : ℝ) / n) k
      ≤ ∑ k ∈ K i, (n.choose k : ℝ) * mlik n k :=
    fun i _ => Finset.sum_le_sum fun k _ => binw_le_choose_mul_mlik n (jsel i) k
  calc ∑ i ∈ I, ∑ k ∈ K i, binw n ((jsel i : ℝ) / n) k
      ≤ ∑ i ∈ I, ∑ k ∈ K i, (n.choose k : ℝ) * mlik n k := Finset.sum_le_sum hstep
    _ = ∑ k ∈ I.biUnion K, (n.choose k : ℝ) * mlik n k := (Finset.sum_biUnion hdisj).symm
    _ ≤ ∑ k ∈ range (n + 1), (n.choose k : ℝ) * mlik n k := by
        refine Finset.sum_le_sum_of_subset_of_nonneg ?_ ?_
        · intro k hk
          rw [Finset.mem_biUnion] at hk
          obtain ⟨i, hi, hki⟩ := hk
          exact hK i hi hki
        · intro k _ _
          have := mlik_nonneg n k
          positivity
    _ = shtarkov (bernClass n) := (shtarkov_bernClass n).symm

/-! ## The `√n` lower bound on the Shtarkov sum -/

section Grid

variable (n : ℕ)

/-- Half-width of the concentration windows: `d ≈ √n`. -/
private noncomputable abbrev dwin : ℕ := Nat.sqrt n + 1

/-- Number of windows minus one. -/
private noncomputable abbrev nwin : ℕ := n / (2 * dwin n)

private noncomputable abbrev center (i : ℕ) : ℕ := 2 * dwin n * i

private noncomputable abbrev window (i : ℕ) : Finset ℕ :=
  (range (n + 1)).filter (fun k => k < center n i + dwin n ∧ center n i < k + dwin n)

private noncomputable abbrev gridIdx (i : ℕ) : Fin (n + 1) :=
  ⟨min (center n i) n, by omega⟩

lemma dwin_pos : 0 < dwin n := Nat.succ_pos _

lemma n_lt_dwin_sq : (n : ℝ) < (dwin n : ℝ) ^ 2 := by
  have h : n < (dwin n) ^ 2 := Nat.lt_succ_sqrt' n
  exact_mod_cast h

lemma center_le (hi : i ≤ nwin n) : center n i ≤ n := by
  have h1 : 2 * dwin n * (n / (2 * dwin n)) ≤ n := by
    calc 2 * dwin n * (n / (2 * dwin n)) = (n / (2 * dwin n)) * (2 * dwin n) := by ring
      _ ≤ n := Nat.div_mul_le_self n (2 * dwin n)
  have h2 : center n i ≤ 2 * dwin n * (n / (2 * dwin n)) := by
    unfold center
    exact Nat.mul_le_mul_left _ hi
  omega

/-- The windows are pairwise disjoint. -/
lemma window_pairwiseDisjoint :
    ((range (nwin n + 1) : Finset ℕ) : Set ℕ).PairwiseDisjoint (window n) := by
  intro i _ i' _ hne
  simp only [Function.onFun]
  rw [Finset.disjoint_left]
  intro k hk hk'
  simp only [window, Finset.mem_filter] at hk hk'
  obtain ⟨-, h1, h2⟩ := hk
  obtain ⟨-, h3, h4⟩ := hk'
  simp only [center] at h1 h2 h3 h4
  have hd : 0 < dwin n := dwin_pos n
  rcases Nat.lt_or_ge i i' with h | h
  · have : 2 * dwin n * i + 2 * dwin n ≤ 2 * dwin n * i' := by
      have : i + 1 ≤ i' := h
      calc 2 * dwin n * i + 2 * dwin n = 2 * dwin n * (i + 1) := by ring
        _ ≤ 2 * dwin n * i' := Nat.mul_le_mul_left _ this
    omega
  · rcases Nat.eq_or_lt_of_le h with h' | h'
    · exact hne h'.symm
    · have : 2 * dwin n * i' + 2 * dwin n ≤ 2 * dwin n * i := by
        have : i' + 1 ≤ i := h'
        calc 2 * dwin n * i' + 2 * dwin n = 2 * dwin n * (i' + 1) := by ring
          _ ≤ 2 * dwin n * i := Nat.mul_le_mul_left _ this
      omega

/-- Each window captures at least three quarters of the mass of its own source. -/
lemma window_mass (hn : 1 ≤ n) {i : ℕ} (hi : i ≤ nwin n) :
    (3/4 : ℝ) ≤ ∑ k ∈ window n i, binw n ((gridIdx n i : ℝ) / n) k := by
  have hnR : (0:ℝ) < n := by exact_mod_cast hn
  have hc : center n i ≤ n := center_le n hi
  have hidx : ((gridIdx n i : Fin (n + 1)) : ℕ) = center n i := by
    show min (center n i) n = center n i
    omega
  set t : ℝ := ((gridIdx n i : Fin (n + 1)) : ℝ) / n with ht
  have htc : (n : ℝ) * t = (center n i : ℝ) := by
    rw [ht]
    have : ((gridIdx n i : Fin (n + 1)) : ℝ) = (center n i : ℝ) := by
      rw [show ((gridIdx n i : Fin (n + 1)) : ℝ) = (((gridIdx n i : Fin (n + 1)) : ℕ) : ℝ) from rfl,
        hidx]
    rw [this]
    field_simp
  have ht0 : 0 ≤ t := (grid_mem_Icc (gridIdx n i)).1
  have ht1 : t ≤ 1 := (grid_mem_Icc (gridIdx n i)).2
  have hd : (0:ℝ) < (dwin n : ℝ) := by
    have := dwin_pos n
    exact_mod_cast this
  have hsub : window n i ⊆ range (n + 1) := Finset.filter_subset _ _
  have hnear : ∀ k ∈ range (n + 1), k ∉ window n i →
      ((dwin n : ℝ)) ^ 2 ≤ ((k : ℝ) - (n : ℝ) * t) ^ 2 := by
    intro k hk hknot
    rw [htc]
    simp only [window, Finset.mem_filter, not_and] at hknot
    have hcases : center n i + dwin n ≤ k ∨ k + dwin n ≤ center n i := by
      by_contra hcon
      push_neg at hcon
      exact absurd (hknot hk hcon.1) (by omega)
    rcases hcases with h | h
    · have : (center n i : ℝ) + (dwin n : ℝ) ≤ (k : ℝ) := by exact_mod_cast h
      nlinarith
    · have : (k : ℝ) + (dwin n : ℝ) ≤ (center n i : ℝ) := by exact_mod_cast h
      nlinarith
  have hconc := binw_concentration (n := n) (t := t) (d := (dwin n : ℝ)) ht0 ht1 hd hsub hnear
  have hvar : (n : ℝ) * t * (1 - t) / (dwin n : ℝ) ^ 2 ≤ 1/4 := by
    have hnum : (n : ℝ) * t * (1 - t) ≤ (n : ℝ) / 4 := by nlinarith [sq_nonneg (t - 1/2)]
    have hden : (n : ℝ) < (dwin n : ℝ) ^ 2 := n_lt_dwin_sq n
    have hd2 : (0:ℝ) < (dwin n : ℝ) ^ 2 := by positivity
    rw [div_le_iff₀ hd2]
    nlinarith
  linarith

/-- **The Shtarkov sum of the memoryless binary class grows like `√n`.** -/
theorem shtarkov_bernClass_ge (hn : 1 ≤ n) :
    (3/4 : ℝ) * ((nwin n : ℝ) + 1) ≤ shtarkov (bernClass n) := by
  have hle := sum_windows_le_shtarkov n (range (nwin n + 1)) (window n)
      (fun i _ => Finset.filter_subset _ _) (window_pairwiseDisjoint n) (gridIdx n)
  refine le_trans ?_ hle
  have hterm : ∀ i ∈ range (nwin n + 1),
      (3/4 : ℝ) ≤ ∑ k ∈ window n i, binw n ((gridIdx n i : ℝ) / n) k := by
    intro i hi
    rw [Finset.mem_range] at hi
    exact window_mass n hn (by omega)
  calc (3/4 : ℝ) * ((nwin n : ℝ) + 1)
      = ∑ _i ∈ range (nwin n + 1), (3/4 : ℝ) := by
        rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
        push_cast
        ring
    _ ≤ ∑ i ∈ range (nwin n + 1), ∑ k ∈ window n i, binw n ((gridIdx n i : ℝ) / n) k :=
        Finset.sum_le_sum hterm

end Grid

/-- `√n / 4` is a lower bound for the Shtarkov sum of the memoryless binary class. -/
theorem shtarkov_bernClass_ge_sqrt (n : ℕ) (hn : 1 ≤ n) :
    Real.sqrt n / 4 ≤ shtarkov (bernClass n) := by
  have hmain := shtarkov_bernClass_ge n hn
  refine le_trans ?_ hmain
  set s : ℝ := Real.sqrt n with hs
  have hs0 : 0 ≤ s := Real.sqrt_nonneg _
  have hsq : s ^ 2 = (n : ℝ) := Real.sq_sqrt (by positivity)
  have hd : 0 < dwin n := dwin_pos n
  have hdR : (0:ℝ) < (dwin n : ℝ) := by exact_mod_cast hd
  -- the number of windows is at least `n / (2 d)`
  have hcount : (n : ℝ) < 2 * (dwin n : ℝ) * ((nwin n : ℝ) + 1) := by
    have hmod : n % (2 * dwin n) < 2 * dwin n := Nat.mod_lt _ (by omega)
    have hdm : 2 * dwin n * nwin n + n % (2 * dwin n) = n := Nat.div_add_mod n (2 * dwin n)
    have hdmR : 2 * (dwin n : ℝ) * (nwin n : ℝ) + ((n % (2 * dwin n) : ℕ) : ℝ) = (n : ℝ) := by
      exact_mod_cast hdm
    have hmodR : ((n % (2 * dwin n) : ℕ) : ℝ) < 2 * (dwin n : ℝ) := by exact_mod_cast hmod
    have hexp : 2 * (dwin n : ℝ) * ((nwin n : ℝ) + 1)
        = 2 * (dwin n : ℝ) * (nwin n : ℝ) + 2 * (dwin n : ℝ) := by ring
    linarith
  -- and `d ≤ √n + 1`
  have hdle : (dwin n : ℝ) ≤ s + 1 := by
    have h1 : (Nat.sqrt n : ℝ) ≤ s := Real.nat_sqrt_le_real_sqrt
    have h2 : ((dwin n : ℕ) : ℝ) = (Nat.sqrt n : ℝ) + 1 := by
      show ((Nat.sqrt n + 1 : ℕ) : ℝ) = (Nat.sqrt n : ℝ) + 1
      push_cast
      ring
    rw [h2]
    linarith
  rcases le_total s 3 with hcase | hcase
  · -- few windows, but there is always at least one
    have h1 : (0:ℝ) ≤ (nwin n : ℝ) := Nat.cast_nonneg _
    linarith
  · -- many windows
    have hs2 : (2:ℝ) ≤ s := by linarith
    have hpos : (0:ℝ) < 2 * (dwin n : ℝ) := by linarith
    have hlow : (n : ℝ) / (2 * (dwin n : ℝ)) < (nwin n : ℝ) + 1 := by
      rw [div_lt_iff₀ hpos]
      linarith [hcount]
    have hchain : s / 3 ≤ (n : ℝ) / (2 * (dwin n : ℝ)) := by
      rw [le_div_iff₀ hpos]
      have h2 : 2 * (dwin n : ℝ) ≤ 2 * (s + 1) := by linarith
      nlinarith
    have : s / 3 < (nwin n : ℝ) + 1 := lt_of_le_of_lt hchain hlow
    linarith

/-! ## Rissanen-style minimax redundancy -/

/-- The logarithmic form of the `√n` bound: the exact minimax regret of the class
of memoryless binary sources is at least `(1/2) log₂ n − 2` bits. -/
theorem logb_shtarkov_bernClass_ge (n : ℕ) (hn : 1 ≤ n) :
    (1/2) * Real.logb 2 n - 2 ≤ Real.logb 2 (shtarkov (bernClass n)) := by
  have hnR : (0:ℝ) < n := by exact_mod_cast hn
  have hone := shtarkov_bernClass_ge_sqrt n hn
  have hsq : (0:ℝ) < Real.sqrt n / 4 := by positivity
  have h2 : logb 2 (Real.sqrt n / 4) ≤ logb 2 (shtarkov (bernClass n)) :=
    Real.logb_le_logb_of_le (by norm_num) hsq hone
  have hs : Real.logb 2 (Real.sqrt n) = (1/2) * Real.logb 2 n := by
    rw [Real.logb, Real.logb, Real.log_sqrt (le_of_lt hnR)]
    ring
  have h4 : Real.logb 2 4 = 2 := by
    rw [show (4:ℝ) = 2 ^ (2:ℕ) by norm_num, Real.logb_pow]
    simp
  rw [Real.logb_div (by positivity) (by norm_num), hs, h4] at h2
  linarith


/-- **The price of universality for memoryless binary sources.** Every code for
binary strings of length `n` pays, on some string and against some member of the
class, a regret of at least `(1/2) log₂ n − 2` bits.  This is Rissanen's
`(k/2) log n` rate for the one-parameter Bernoulli family, with explicit
constants. -/
theorem bernoulli_regret_ge_half_logb (n : ℕ) (hn : 1 ≤ n) {L : Msg n → ℕ}
    (hL : IsCode L) :
    ∃ (j : Fin (n + 1)) (s : Msg n),
      (1/2) * Real.logb 2 n - 2 ≤ (L s : ℝ) + Real.logb 2 (bernClass n j s) := by
  obtain ⟨j, s, hjs⟩ :=
    code_regret_ge_logb_shtarkov (p := bernClass n) (L := L) (bernClass_isPMF n) hL
  exact ⟨j, s, le_trans (logb_shtarkov_bernClass_ge n hn) hjs⟩

end PriceOfUniversality