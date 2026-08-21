/-
# Removing the window loss: the sharp interval constant `1 / log (1/δ)`

`Bridges.DenseSumsetLower.Core` runs the greedy shift argument inside `[0,n)` with the full
difference window `(-n, n)`, which costs a factor `2` and produces the constant
`1 / log (2/δ)`.  This file removes that loss.

The point is that the greedy iteration never needs `D` to contain *all* differences of `S`:
it only needs a uniform lower bound

  `m ≤ #{a ∈ D : u + a ∈ S}`  for every `u` in the starting set `U₀`.

Confining `U₀` to a *short window* of length `w` inside `[0,n)` makes this true with
`m = |S| - (w - 1)` and `|D| = n - w + 1`, i.e. with a window of size `n` rather than `2n`.
A pigeonhole choice of the window keeps `|U₀| ≳ |S| w / n`, which costs only a constant
factor and hence nothing in the exponent.

Contents:

* `DenseSumsetLower.sum_card_filter_shift_ge`, `exists_good_shift_ge`,
  `exists_greedy_family_ge`, `exists_sumset_of_counting_ge` — the greedy engine in the
  generality of an additive commutative monoid, with the hypothesis above;
* `DenseSumsetLower.exists_sumset_nat_window` — the finitary interval statement with the
  improved window;
* `DenseSumsetLower.exists_sumset_of_density_sharp` and
  `DenseSumsetLower.eventually_exists_sumset_sharp` — the density and asymptotic forms, with
  the constant `1 / log (1/δ)`.
-/
import Bridges.DenseSumsetLower.Density

namespace DenseSumsetLower

open Finset Pointwise Filter

/-! ## The greedy engine with a one-sided counting hypothesis -/

variable {M : Type*} [AddCommMonoid M] [DecidableEq M]

/-- **Averaging, one-sided form.**  If every `u ∈ U` admits at least `m` shifts `a ∈ D`
with `u + a ∈ S`, then the double count `∑_{a ∈ D} #{u ∈ U : u + a ∈ S}` is at least
`|U| m`.  No hypothesis relating `D` to the differences of `S` is needed. -/
theorem sum_card_filter_shift_ge {S D U : Finset M} {m : ℕ}
    (hm : ∀ u ∈ U, m ≤ (D.filter (fun a => u + a ∈ S)).card) :
    U.card * m ≤ ∑ a ∈ D, (U.filter (fun u => u + a ∈ S)).card := by
  classical
  have h1 : ∀ a ∈ D, (U.filter (fun u => u + a ∈ S)).card
      = ∑ u ∈ U, if u + a ∈ S then 1 else 0 := by
    intro a _; rw [Finset.card_filter]
  rw [Finset.sum_congr rfl h1, Finset.sum_comm]
  calc U.card * m = ∑ _u ∈ U, m := by rw [Finset.sum_const, smul_eq_mul]
    _ ≤ ∑ u ∈ U, ∑ a ∈ D, if u + a ∈ S then 1 else 0 := by
        refine Finset.sum_le_sum ?_
        intro u hu
        rw [← Finset.card_filter]
        exact hm u hu

/-- **One greedy step, one-sided form.** -/
theorem exists_good_shift_ge {S D U F : Finset M} {m : ℕ}
    (hm : ∀ u ∈ U, m ≤ (D.filter (fun a => u + a ∈ S)).card) (hFD : F.card < D.card) :
    ∃ a ∈ D, a ∉ F ∧
      U.card * m ≤ D.card * (U.filter (fun u => u + a ∈ S)).card + F.card * U.card := by
  classical
  set f : M → ℕ := fun a => (U.filter (fun u => u + a ∈ S)).card with hf
  have hsum : U.card * m ≤ ∑ a ∈ D, f a := sum_card_filter_shift_ge hm
  have hne : (D \ F).Nonempty := by
    rw [← Finset.card_pos]
    have := Finset.card_le_card_sdiff_add_card (s := D) (t := F)
    omega
  obtain ⟨a₀, ha₀, hmax⟩ := Finset.exists_max_image (D \ F) f hne
  refine ⟨a₀, (Finset.mem_sdiff.mp ha₀).1, (Finset.mem_sdiff.mp ha₀).2, ?_⟩
  have hsplit : ∑ a ∈ D ∩ F, f a + ∑ a ∈ D \ F, f a = ∑ a ∈ D, f a :=
    Finset.sum_inter_add_sum_diff D F f
  have h2 : ∑ a ∈ D \ F, f a ≤ (D \ F).card * f a₀ := by
    calc ∑ a ∈ D \ F, f a ≤ ∑ _a ∈ D \ F, f a₀ := Finset.sum_le_sum (fun a ha => hmax a ha)
      _ = (D \ F).card * f a₀ := by simp
  have h3 : ∑ a ∈ D ∩ F, f a ≤ F.card * U.card := by
    calc ∑ a ∈ D ∩ F, f a ≤ ∑ _a ∈ D ∩ F, U.card :=
          Finset.sum_le_sum (fun a _ => Finset.card_filter_le _ _)
      _ = (D ∩ F).card * U.card := by simp
      _ ≤ F.card * U.card := Nat.mul_le_mul_right _ (Finset.card_le_card Finset.inter_subset_right)
  have h4 : (D \ F).card ≤ D.card := Finset.card_le_card Finset.sdiff_subset
  calc U.card * m ≤ ∑ a ∈ D ∩ F, f a + ∑ a ∈ D \ F, f a := by rw [hsplit]; exact hsum
    _ ≤ F.card * U.card + D.card * f a₀ :=
        Nat.add_le_add h3 (le_trans h2 (Nat.mul_le_mul_right _ h4))
    _ = D.card * f a₀ + F.card * U.card := by ring

/-- **The greedy iteration, one-sided form.**  After `j ≤ k` steps we have `j` distinct
shifts `A ⊆ D` and a surviving set `U ⊆ U₀` with `U + A ⊆ S` and
`|U| ≥ |U₀| ((m - k)/|D|)^j`. -/
theorem exists_greedy_family_ge {S D U₀ : Finset M} {m k : ℕ}
    (hm : ∀ u ∈ U₀, m ≤ (D.filter (fun a => u + a ∈ S)).card)
    (hkm : k ≤ m) (hkD : k ≤ D.card) :
    ∀ j ≤ k, ∃ A U : Finset M, A ⊆ D ∧ A.card = j ∧ U ⊆ U₀ ∧
      (∀ a ∈ A, ∀ u ∈ U, u + a ∈ S) ∧
      U₀.card * (m - k) ^ j ≤ U.card * D.card ^ j := by
  classical
  intro j
  induction j with
  | zero => intro _; exact ⟨∅, U₀, by simp, by simp, Finset.Subset.refl U₀, by simp, by simp⟩
  | succ j ih =>
      intro hj
      obtain ⟨A, U, hAD, hAcard, hUU₀, hAU, hbound⟩ := ih (Nat.le_of_succ_le hj)
      have hAcd : A.card < D.card := by omega
      have hmU : ∀ u ∈ U, m ≤ (D.filter (fun a => u + a ∈ S)).card :=
        fun u hu => hm u (hUU₀ hu)
      obtain ⟨a, haD, haA, hstep⟩ := exists_good_shift_ge hmU hAcd
      set U' := U.filter (fun u => u + a ∈ S) with hU'
      refine ⟨insert a A, U', Finset.insert_subset haD hAD, ?_,
        (Finset.filter_subset _ _).trans hUU₀, ?_, ?_⟩
      · rw [Finset.card_insert_of_notMem haA, hAcard]
      · intro b hb u hu
        rcases Finset.mem_insert.mp hb with rfl | hbA
        · exact (Finset.mem_filter.mp hu).2
        · exact hAU b hbA u (Finset.mem_filter.mp hu).1
      · have hkey : U.card * (m - k) ≤ D.card * U'.card := by
          have h1 : U.card * (m - k) + A.card * U.card ≤ U.card * m := by
            rw [hAcard]
            have hjs : (m - k) + j ≤ m := by omega
            calc U.card * (m - k) + j * U.card = U.card * ((m - k) + j) := by ring
              _ ≤ U.card * m := Nat.mul_le_mul_left _ hjs
          omega
        calc U₀.card * (m - k) ^ (j + 1)
            = (U₀.card * (m - k) ^ j) * (m - k) := by ring
          _ ≤ (U.card * D.card ^ j) * (m - k) := Nat.mul_le_mul_right _ hbound
          _ = (U.card * (m - k)) * D.card ^ j := by ring
          _ ≤ (D.card * U'.card) * D.card ^ j := Nat.mul_le_mul_right _ hkey
          _ = U'.card * D.card ^ (j + 1) := by ring

/-- **Abstract sumset existence, one-sided form.**  If every `u ∈ U₀` has at least `m`
shifts in `D` landing in `S`, and `k |D|^k ≤ |U₀| (m - k)^k`, then `S ⊇ A + B` with
`A ⊆ D`, `B ⊆ U₀` and `|A| = |B| = k`. -/
theorem exists_sumset_of_counting_ge {S D U₀ : Finset M} {m k : ℕ}
    (hm : ∀ u ∈ U₀, m ≤ (D.filter (fun a => u + a ∈ S)).card)
    (hkm : k ≤ m) (hkD : k ≤ D.card)
    (hcond : k * D.card ^ k ≤ U₀.card * (m - k) ^ k) :
    ∃ A B : Finset M, A ⊆ D ∧ B ⊆ U₀ ∧ A.card = k ∧ B.card = k ∧ A + B ⊆ S := by
  classical
  obtain ⟨A, U, hAD, hAcard, hUU₀, hAU, hbound⟩ := exists_greedy_family_ge hm hkm hkD k le_rfl
  have hDpos : 0 < D.card ^ k := by
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · simp
    · exact Nat.pow_pos (by omega)
  have hUk : k ≤ U.card :=
    Nat.le_of_mul_le_mul_right (le_trans hcond hbound) hDpos
  obtain ⟨B, hBU, hBcard⟩ := Finset.exists_subset_card_eq hUk
  refine ⟨A, B, hAD, hBU.trans hUU₀, hAcard, hBcard, ?_⟩
  intro x hx
  obtain ⟨a, ha, b, hb, rfl⟩ := Finset.mem_add.mp hx
  have := hAU a ha b (hBU hb)
  rwa [add_comm] at this

/-! ## Short windows inside an interval -/

/-- **Shift count from a short window.**  For `u < w ≤ n` and `S ⊆ [0,n)`, at least
`|S| - (w - 1)` of the `n - w + 1` shifts `a ∈ [0, n-w]` satisfy `u + a ∈ S`: the translate
`u + [0, n-w]` misses only `w - 1` points of `[0,n)`. -/
theorem card_shift_window {n w u : ℕ} {S : Finset ℕ} (hS : S ⊆ Finset.range n)
    (hwn : w ≤ n) (hu : u < w) :
    S.card - (w - 1) ≤ ((Finset.range (n - w + 1)).filter (fun a => u + a ∈ S)).card := by
  classical
  have hbij : ((Finset.range (n - w + 1)).filter (fun a => u + a ∈ S)).card
      = (S.filter (fun s => u ≤ s ∧ s ≤ u + (n - w))).card := by
    refine Finset.card_nbij (fun a => u + a) ?_ ?_ ?_
    · intro a ha
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range] at ha ⊢
      exact ⟨ha.2, by omega⟩
    · intro a₁ _ a₂ _ h
      simpa using h
    · intro s hs
      simp only [Finset.coe_filter, Set.mem_setOf_eq] at hs
      obtain ⟨hsS, hs1, hs2⟩ := hs
      refine ⟨s - u, ?_, by show u + (s - u) = s; omega⟩
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range]
      refine ⟨by omega, ?_⟩
      have hrw : u + (s - u) = s := by omega
      rw [hrw]; exact hsS
  rw [hbij]
  have hcompl : (S.filter (fun s => ¬ (u ≤ s ∧ s ≤ u + (n - w)))).card ≤ w - 1 := by
    have hIcc : Finset.Icc u (u + (n - w)) ⊆ Finset.range n := by
      intro s hs
      obtain ⟨h1, h2⟩ := Finset.mem_Icc.mp hs
      exact Finset.mem_range.mpr (by omega)
    have hsub : S.filter (fun s => ¬ (u ≤ s ∧ s ≤ u + (n - w)))
        ⊆ Finset.range n \ Finset.Icc u (u + (n - w)) := by
      intro s hs
      obtain ⟨hsS, hsP⟩ := Finset.mem_filter.mp hs
      exact Finset.mem_sdiff.mpr ⟨hS hsS, fun hmem => hsP (Finset.mem_Icc.mp hmem)⟩
    have hcard : (Finset.range n \ Finset.Icc u (u + (n - w))).card = w - 1 := by
      rw [Finset.card_sdiff_of_subset hIcc, Nat.card_Icc, Finset.card_range]
      omega
    calc (S.filter (fun s => ¬ (u ≤ s ∧ s ≤ u + (n - w)))).card
        ≤ (Finset.range n \ Finset.Icc u (u + (n - w))).card := Finset.card_le_card hsub
      _ = w - 1 := hcard
  have hsplit := Finset.card_filter_add_card_filter_not
    (s := S) (p := fun s => u ≤ s ∧ s ≤ u + (n - w))
  omega

/-- **The interval statement with a short window.**  Let `S ⊆ [0,n)`, let `0 < w ≤ n` be a
window length and put `q = ⌈n/w⌉`.  If `p + k + (w-1) ≤ |S|` and
`q · k · (n - w + 1)^k ≤ |S| · p^k`, then `S` contains a sumset `A + B` with `|A| = |B| = k`.

Compared with `DenseSumsetLower.exists_sumset_nat_range` the shift window has size
`n - w + 1` instead of `2n`; the price is the pigeonhole factor `q ≈ n/w`, a constant when
`w` is a constant fraction of `n`, which therefore does not affect the exponent. -/
theorem exists_sumset_nat_window {n w k p : ℕ} {S : Finset ℕ} (hS : S ⊆ Finset.range n)
    (hw : 0 < w) (hwn : w ≤ n) (hkD : k ≤ n - w + 1)
    (hp : p + k + (w - 1) ≤ S.card)
    (hcond : ((n + w - 1) / w) * (k * (n - w + 1) ^ k) ≤ S.card * p ^ k) :
    ∃ A B : Finset ℕ, A.card = k ∧ B.card = k ∧ A + B ⊆ S := by
  classical
  set q : ℕ := (n + w - 1) / w with hq
  have hnpos : 0 < n := by omega
  have hqval : q = (n - 1) / w + 1 := by
    have hrw : n + w - 1 = (n - 1) + w := by omega
    rw [hq, hrw, Nat.add_div_right _ hw]
  have hqpos : 0 < q := by rw [hqval]; exact Nat.succ_pos _
  have hmaps : Set.MapsTo (fun s => s / w) (S : Set ℕ) ((Finset.range q : Finset ℕ) : Set ℕ) := by
    intro s hs
    have hsn : s < n := Finset.mem_range.mp (hS hs)
    have h1 : s / w ≤ (n - 1) / w := Nat.div_le_div_right (by omega)
    simp only [Finset.coe_range, Set.mem_Iio]
    omega
  have hsum : S.card = ∑ i ∈ Finset.range q, (S.filter (fun s => s / w = i)).card :=
    Finset.card_eq_sum_card_fiberwise hmaps
  obtain ⟨i, _, hicard⟩ :
      ∃ i ∈ Finset.range q, S.card ≤ q * (S.filter (fun s => s / w = i)).card := by
    refine Finset.exists_le_of_sum_le ⟨0, Finset.mem_range.mpr hqpos⟩ ?_
    rw [Finset.sum_const, Finset.card_range, smul_eq_mul, ← Finset.mul_sum, ← hsum]
  set F : Finset ℕ := S.filter (fun s => s / w = i) with hF
  have hFmem : ∀ s ∈ F, s ∈ S ∧ w * i ≤ s ∧ s < w * i + w := by
    intro s hs
    obtain ⟨hsS, hsi⟩ := Finset.mem_filter.mp hs
    have hdm := Nat.div_add_mod s w
    have hmod : s % w < w := Nat.mod_lt _ hw
    rw [hsi] at hdm
    exact ⟨hsS, by omega, by omega⟩
  set U₀ : Finset ℕ := F.image (fun s => s - w * i) with hU₀
  have hU₀card : U₀.card = F.card := by
    refine Finset.card_image_of_injOn ?_
    intro a ha b hb hab
    have h1 := hFmem a ha
    have h2 := hFmem b hb
    simp only at hab
    omega
  have hU₀lt : ∀ u ∈ U₀, u < w := by
    intro u hu
    obtain ⟨s, hs, rfl⟩ := Finset.mem_image.mp hu
    have := hFmem s hs
    omega
  have hm : ∀ u ∈ U₀, p + k ≤
      ((Finset.range (n - w + 1)).filter (fun a => u + a ∈ S)).card := by
    intro u hu
    have hcw := card_shift_window hS hwn (hU₀lt u hu)
    omega
  have hDcard : (Finset.range (n - w + 1)).card = n - w + 1 := Finset.card_range _
  have hcond2 : k * (Finset.range (n - w + 1)).card ^ k ≤ U₀.card * ((p + k) - k) ^ k := by
    rw [hDcard, hU₀card]
    have hstep : q * (k * (n - w + 1) ^ k) ≤ q * (F.card * p ^ k) := by
      calc q * (k * (n - w + 1) ^ k) ≤ S.card * p ^ k := hcond
        _ ≤ (q * F.card) * p ^ k := Nat.mul_le_mul_right _ hicard
        _ = q * (F.card * p ^ k) := by ring
    have hfin := Nat.le_of_mul_le_mul_left hstep hqpos
    simpa using hfin
  obtain ⟨A, B, _, _, hAcard, hBcard, hAB⟩ :=
    exists_sumset_of_counting_ge hm (Nat.le_add_left k p) (by rw [hDcard]; exact hkD) hcond2
  exact ⟨A, B, hAcard, hBcard, hAB⟩

/-! ## The density form and the sharp constant -/

/-- **Real-parameter form of the window criterion.**  If the window length `w` and the
parameters `mu` (a lower bound for the surviving density) and `Q` (an upper bound for the
pigeonhole factor `⌈n/w⌉`) satisfy `mu + k + (w-1) ≤ |S|` and `Q k n^k ≤ |S| mu^k`, then `S`
contains a sumset `A + B` with `|A| = |B| = k`. -/
theorem exists_sumset_window_real {n k w : ℕ} {S : Finset ℕ} (hS : S ⊆ Finset.range n)
    {mu Q : ℝ} (hw : 0 < w) (hwn : w ≤ n) (hkD : k ≤ n - w + 1) (hmu0 : 0 < mu)
    (hmu : mu + (k : ℝ) + ((w : ℝ) - 1) ≤ (S.card : ℝ))
    (hQ : (((n + w - 1) / w : ℕ) : ℝ) ≤ Q)
    (hcond : Q * ((k : ℝ) * (n : ℝ) ^ k) ≤ (S.card : ℝ) * mu ^ k) :
    ∃ A B : Finset ℕ, A.card = k ∧ B.card = k ∧ A + B ⊆ S := by
  classical
  have hw1 : 1 ≤ w := hw
  have hcastw : ((w - 1 : ℕ) : ℝ) = (w : ℝ) - 1 := by
    rw [Nat.cast_sub hw1, Nat.cast_one]
  have hkw : k + (w - 1) ≤ S.card := by
    have hR : ((k + (w - 1) : ℕ) : ℝ) ≤ (S.card : ℝ) := by
      push_cast [hcastw]
      linarith
    exact_mod_cast hR
  have h1 : k ≤ S.card := by omega
  have h2 : w - 1 ≤ S.card - k := by omega
  set p : ℕ := S.card - k - (w - 1) with hp
  have hpk : p + k + (w - 1) ≤ S.card := by omega
  have hpR : (p : ℝ) = (S.card : ℝ) - k - ((w : ℝ) - 1) := by
    rw [hp, Nat.cast_sub h2, Nat.cast_sub h1, hcastw]
  have hmup : mu ≤ (p : ℝ) := by rw [hpR]; linarith
  have hDle : (((n - w + 1 : ℕ)) : ℝ) ≤ (n : ℝ) := by
    have hle : n - w + 1 ≤ n := by omega
    exact_mod_cast hle
  have hDle' : ∀ dd : ℕ, dd = n - w + 1 → ((dd : ℕ) : ℝ) ≤ (n : ℝ) := by
    intro dd h; rw [h]; exact hDle
  set dd : ℕ := n - w + 1 with hdd
  refine exists_sumset_nat_window hS hw hwn hkD hpk ?_
  have hQ0 : 0 ≤ Q := le_trans (Nat.cast_nonneg _) hQ
  have hkey : (((((n + w - 1) / w : ℕ)) * (k * dd ^ k) : ℕ) : ℝ)
      ≤ ((S.card * p ^ k : ℕ) : ℝ) := by
    push_cast
    calc ((((n + w - 1) / w : ℕ)) : ℝ) * ((k : ℝ) * ((dd : ℕ) : ℝ) ^ k)
        ≤ Q * ((k : ℝ) * (n : ℝ) ^ k) := by
          have hstep : (k : ℝ) * ((dd : ℕ) : ℝ) ^ k ≤ (k : ℝ) * (n : ℝ) ^ k :=
            mul_le_mul_of_nonneg_left
              (pow_le_pow_left₀ (Nat.cast_nonneg _) (hDle' dd hdd) k) (Nat.cast_nonneg _)
          exact mul_le_mul hQ hstep (by positivity) hQ0
      _ ≤ (S.card : ℝ) * mu ^ k := hcond
      _ ≤ (S.card : ℝ) * (p : ℝ) ^ k :=
          mul_le_mul_of_nonneg_left (pow_le_pow_left₀ (le_of_lt hmu0) hmup k) (Nat.cast_nonneg _)
  exact_mod_cast hkey

/-- **The sharp asymptotic lower bound.**  Fix `0 < δ < 1` and any `c` with
`c log (1/δ) < 1`.  Then for all large `n`, *every* `S ⊆ [n]` with `|S| ≥ δ n` contains a
sumset `A + B` with `|A| = |B| = ⌊c log n⌋`.

This removes the factor `2` of `DenseSumsetLower.eventually_exists_sumset_of_density`: the
extremal threshold for `δ`-dense subsets of `[n]` is at least `(1 - o(1)) log n / log (1/δ)`,
matching the finite-group bound `DenseSumsetLower.exists_threshold_group`. -/
theorem eventually_exists_sumset_sharp {δ c : ℝ} (hδ0 : 0 < δ) (hδ1 : δ < 1)
    (hc0 : 0 < c) (hc : c * Real.log (1 / δ) < 1) :
    ∀ᶠ n : ℕ in atTop, ∀ S : Finset ℕ, S ⊆ Finset.range n → δ * (n : ℝ) ≤ S.card →
      ∃ A B : Finset ℕ, A.card = ⌊c * Real.log n⌋₊ ∧ B.card = ⌊c * Real.log n⌋₊ ∧
        A + B ⊆ S := by
  set t : ℝ := 1 - c * Real.log (1 / δ) with ht
  have htpos : 0 < t := by simp only [ht]; linarith
  set r : ℝ := Real.exp (-(t / (2 * c))) with hr
  have hr0 : 0 < r := Real.exp_pos _
  have hr1 : r < 1 := by
    have harg : -(t / (2 * c)) < 0 := by
      have : 0 < t / (2 * c) := by positivity
      linarith
    rw [hr]
    exact Real.exp_lt_one_iff.mpr harg
  set ee : ℝ := δ * (1 - r) / 2 with hee
  have hee0 : 0 < ee := by
    rw [hee]
    have : 0 < 1 - r := by linarith
    positivity
  have heeδ : 2 * ee ≤ δ := by
    rw [hee]
    nlinarith
  have hee1 : ee < 1 / 2 := by linarith
  set d0 : ℝ := δ * r with hd0
  have hd00 : 0 < d0 := by rw [hd0]; positivity
  have hd0e : d0 = δ - 2 * ee := by rw [hd0, hee]; ring
  have hd01 : d0 < 1 := by
    have : d0 ≤ δ := by rw [hd0e]; linarith
    linarith
  set b : ℝ := 1 / d0 with hb
  have hb1 : 1 < b := by rw [hb, lt_div_iff₀ hd00]; linarith
  have hb0 : 0 < b := lt_trans zero_lt_one hb1
  have hlogb : Real.log b = Real.log (1 / δ) + t / (2 * c) := by
    have hbe : b = (1 / δ) * Real.exp (t / (2 * c)) := by
      rw [hb, hd0, hr, Real.exp_neg]
      field_simp
    rw [hbe, Real.log_mul (by positivity) (Real.exp_ne_zero _), Real.log_exp]
  have hcb : c * Real.log b < 1 := by
    have hct : c * (t / (2 * c)) = t / 2 := by field_simp
    rw [hlogb, mul_add, hct, ht]
    linarith
  set Q : ℝ := 1 / ee + 1 with hQ
  have hQ0 : 0 < Q := by
    rw [hQ]
    have : 0 < 1 / ee := by positivity
    linarith
  have hδQ : δ / Q ≤ ee := by
    rw [div_le_iff₀ hQ0, hQ]
    have hid : ee * (1 / ee + 1) = 1 + ee := by field_simp
    rw [hid]
    linarith
  have hα : 0 < δ / Q := by positivity
  filter_upwards [eventually_floor_log_pow_le hb1 hc0 hcb hα,
    eventually_ge_atTop (⌈4 / ee⌉₊ + 4)] with n hn hnbig S hS hdense
  obtain ⟨hn1, hn2⟩ := hn
  set k : ℕ := ⌊c * Real.log n⌋₊ with hk
  have hnR : (1 : ℝ) ≤ (n : ℝ) := hn1
  have hnpos : (0 : ℝ) < (n : ℝ) := lt_of_lt_of_le zero_lt_one hnR
  have hnbigR : (4 : ℝ) / ee ≤ (n : ℝ) := by
    have h1 : ((⌈4 / ee⌉₊ : ℕ) : ℝ) ≤ (n : ℝ) := by
      exact_mod_cast le_trans (Nat.le_add_right _ 4) hnbig
    exact le_trans (Nat.le_ceil _) h1
  have hn8 : (8 : ℝ) ≤ (n : ℝ) := by
    have h8 : (8 : ℝ) ≤ 4 / ee := by
      rw [le_div_iff₀ hee0]
      linarith
    linarith
  -- `k ≤ ee * n`
  have hkee : (k : ℝ) ≤ ee * n := by
    have hbk : (1 : ℝ) ≤ b ^ k := one_le_pow₀ (le_of_lt hb1)
    have hknn : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
    have hstep : (k : ℝ) ≤ (k : ℝ) * b ^ k := by nlinarith
    have h1 : (k : ℝ) ≤ (δ / Q) * n := le_trans hstep hn2
    have h2 : (δ / Q) * n ≤ ee * n := mul_le_mul_of_nonneg_right hδQ (le_of_lt hnpos)
    linarith
  have heen : ee * (n : ℝ) ≤ (1 / 2) * n :=
    mul_le_mul_of_nonneg_right (le_of_lt hee1) (le_of_lt hnpos)
  -- the window
  set w : ℕ := ⌈ee * (n : ℝ)⌉₊ with hw
  have hwlow : ee * (n : ℝ) ≤ (w : ℝ) := Nat.le_ceil _
  have hwhigh : (w : ℝ) < ee * (n : ℝ) + 1 := Nat.ceil_lt_add_one (by positivity)
  have hwpos : 0 < w := by
    have hpos : (0 : ℝ) < (w : ℝ) := lt_of_lt_of_le (by positivity) hwlow
    exact_mod_cast hpos
  have hwn : w ≤ n := by
    have hR : (w : ℝ) ≤ (n : ℝ) := by linarith
    exact_mod_cast hR
  have hcastD : (((n - w + 1 : ℕ)) : ℝ) = (n : ℝ) - (w : ℝ) + 1 := by
    rw [Nat.cast_add, Nat.cast_sub hwn, Nat.cast_one]
  have hkD : k ≤ n - w + 1 := by
    have hR : (k : ℝ) ≤ (((n - w + 1 : ℕ)) : ℝ) := by rw [hcastD]; linarith
    exact_mod_cast hR
  -- the parameters
  set mu : ℝ := (n : ℝ) / b with hmu
  have hmu0 : 0 < mu := by rw [hmu]; positivity
  have hmue : mu = d0 * n := by
    rw [hmu, hb]
    field_simp
  have hmucond : mu + (k : ℝ) + ((w : ℝ) - 1) ≤ (S.card : ℝ) := by
    have hexp : d0 * (n : ℝ) = δ * n - 2 * (ee * n) := by
      rw [hd0e]; ring
    rw [hmue, hexp]
    linarith
  have hQcond : ((((n + w - 1) / w : ℕ)) : ℝ) ≤ Q := by
    have hle : ((((n + w - 1) / w : ℕ)) : ℝ) ≤ ((n + w - 1 : ℕ) : ℝ) / (w : ℝ) :=
      Nat.cast_div_le
    have hnum : ((n + w - 1 : ℕ) : ℝ) = (n : ℝ) + (w : ℝ) - 1 := by
      have h1 : 1 ≤ n + w := by omega
      rw [Nat.cast_sub h1, Nat.cast_add, Nat.cast_one]
    have hwR : (0 : ℝ) < (w : ℝ) := by exact_mod_cast hwpos
    have hn_le : (n : ℝ) ≤ (1 / ee) * (w : ℝ) := by
      rw [div_mul_eq_mul_div, le_div_iff₀ hee0]
      linarith
    have hstep : ((n : ℝ) + (w : ℝ) - 1) / (w : ℝ) ≤ Q := by
      rw [div_le_iff₀ hwR, hQ]
      have hid : (1 / ee + 1) * (w : ℝ) = (1 / ee) * (w : ℝ) + (w : ℝ) := by ring
      rw [hid]
      linarith
    rw [hnum] at hle
    linarith
  refine exists_sumset_window_real hS hwpos hwn hkD hmu0 hmucond hQcond ?_
  -- the counting condition
  have hbk : (0 : ℝ) < b ^ k := by positivity
  have hbkne : (b : ℝ) ^ k ≠ 0 := ne_of_gt hbk
  have h1 : Q * ((k : ℝ) * b ^ k) ≤ δ * n := by
    have hmul := mul_le_mul_of_nonneg_left hn2 (le_of_lt hQ0)
    have hid : Q * ((δ / Q) * n) = δ * n := by field_simp
    linarith [hid ▸ hmul]
  have hmupow : mu ^ k = (n : ℝ) ^ k / b ^ k := by rw [hmu, div_pow]
  have hid2 : (Q * ((k : ℝ) * b ^ k)) * ((n : ℝ) ^ k / b ^ k) = Q * ((k : ℝ) * (n : ℝ) ^ k) := by
    field_simp
  calc Q * ((k : ℝ) * (n : ℝ) ^ k)
      = (Q * ((k : ℝ) * b ^ k)) * ((n : ℝ) ^ k / b ^ k) := hid2.symm
    _ ≤ (δ * n) * ((n : ℝ) ^ k / b ^ k) :=
        mul_le_mul_of_nonneg_right h1 (by positivity)
    _ ≤ (S.card : ℝ) * mu ^ k := by
        rw [hmupow]
        exact mul_le_mul_of_nonneg_right hdense (by positivity)

end DenseSumsetLower