/-
# The price of universality, VI: sharpness, non-vacuity and the two-sided rate

Adversarial review of the preceding files.  Two questions are settled here.

**1. Are the hypotheses of the "exact price" theorems satisfiable?**
`indicatorClass_sandwich` exhibits a concrete class — the `m` deterministic
sources on an alphabet of size `m` — that satisfies every hypothesis of
`price_of_universality_sandwich` and `minimax_regret_disjoint`, so those results
are not vacuous.  For this class the general theory specialises to a sharp
pigeonhole statement about code lengths, `exists_length_ge_logb_card`: any Kraft
code on `m` messages assigns some message a length of at least `log₂ m`.

**2. Is the `(1/2) log₂ n` lower bound of the Bernoulli class of the right
order?**  `shtarkov_bernClass_le` shows `S ≤ n + 1`, hence the exact minimax
regret of the memoryless binary class of block length `n` obeys

  `(1/2) log₂ n − 2  ≤  regret  ≤  log₂ (n + 1)`.

So the truth is pinned between `(1/2) log₂ n` and `log₂ n`; the classical
`(1/2) log₂ n + O(1)` answer sits at the lower end, and no bound better than
linear in `log n` is possible.  Closing the factor-of-two gap requires the
Stirling-type estimate discussed in `FUTURE_DIRECTIONS.md`.
-/
import Novelty.UniversalRedundancyProduct

namespace PriceOfUniversality

open Finset Real

/-! ## Bridge: the average-case price never exceeds the worst-case price -/

section Bridge

variable {A : Type*} [Fintype A] [Nonempty A] {Θ : Type*} [Fintype Θ] [Nonempty Θ]

omit [Nonempty A] in
/-- Every member of the class is within `log₂ S` bits of NML *on average*, not just
pointwise. -/
theorem kl_nml_le_logb_shtarkov {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ))
    (hpos : ∀ a, 0 < maxLik p a) (θ : Θ) :
    kl (p θ) (nml p) ≤ logb 2 (shtarkov p) := by
  have hS := shtarkov_pos hp
  have hterm : ∀ a : A, p θ a * logb 2 (p θ a / nml p a) ≤ p θ a * logb 2 (shtarkov p) := by
    intro a
    rcases eq_or_lt_of_le ((hp θ).nonneg a) with h | h
    · simp [← h]
    · have hnml : 0 < nml p a := div_pos (hpos a) hS
      have hratio : p θ a / nml p a ≤ shtarkov p := by
        rw [div_le_iff₀ hnml]
        have := nml_regret_le hp θ a
        linarith
      have hlog : logb 2 (p θ a / nml p a) ≤ logb 2 (shtarkov p) :=
        Real.logb_le_logb_of_le (by norm_num) (by positivity) hratio
      exact mul_le_mul_of_nonneg_left hlog h.le
  calc kl (p θ) (nml p) = ∑ a, p θ a * logb 2 (p θ a / nml p a) := rfl
    _ ≤ ∑ a, p θ a * logb 2 (shtarkov p) := Finset.sum_le_sum fun a _ => hterm a
    _ = logb 2 (shtarkov p) := by rw [← Finset.sum_mul, (hp θ).total, one_mul]

omit [Nonempty A] in
/-- **The average-case price of universality never exceeds the worst-case price.**
For every prior on the class, the mutual information (the average-case price of
`exists_source_redundancy_ge_mutualInfo`) is at most `log₂ S` (the exact
worst-case price of `minimax_regret_eq_logb_shtarkov`). -/
theorem mutualInfo_le_logb_shtarkov {pri : Θ → ℝ} {p : Θ → A → ℝ}
    (hpri : IsPMF pri) (hpripos : ∀ θ, 0 < pri θ) (hp : ∀ θ, IsPMF (p θ))
    (hpos : ∀ a, 0 < maxLik p a) :
    mutualInfo pri p ≤ logb 2 (shtarkov p) := by
  have hS := shtarkov_pos hp
  have hnmlpos : ∀ a : A, 0 < nml p a := fun a => div_pos (hpos a) hS
  have hcomp := kl_compensation hpri hpripos hp hnmlpos
  have hklnn : 0 ≤ kl (mixture pri p) (nml p) :=
    kl_nonneg (mixture_isPMF hpri hp) hnmlpos (le_of_eq (nml_isPMF hp).total)
  have havg : ∑ θ, pri θ * kl (p θ) (nml p) ≤ logb 2 (shtarkov p) := by
    calc ∑ θ, pri θ * kl (p θ) (nml p)
        ≤ ∑ θ, pri θ * logb 2 (shtarkov p) :=
          Finset.sum_le_sum fun θ _ =>
            mul_le_mul_of_nonneg_left (kl_nml_le_logb_shtarkov hp hpos θ) (hpri.nonneg θ)
      _ = logb 2 (shtarkov p) := by rw [← Finset.sum_mul, hpri.total, one_mul]
  linarith

end Bridge

/-! ## A concrete class realising the exact price `log₂ m` -/

/-- The class of `m` deterministic sources on an alphabet of `m` letters: source
`θ` emits the letter `θ` with certainty.  These are perfectly distinguishable. -/
noncomputable def indicatorClass (m : ℕ) : Fin m → Fin m → ℝ :=
  fun θ a => if a = θ then 1 else 0

variable {m : ℕ}

theorem indicatorClass_isPMF (θ : Fin m) : IsPMF (indicatorClass m θ) := by
  refine ⟨fun a => by unfold indicatorClass; split <;> norm_num, ?_⟩
  simp [indicatorClass]

theorem indicatorClass_disjoint : DisjointSupports (indicatorClass m) := by
  intro θ θ' a hne hpos
  simp only [indicatorClass] at hpos ⊢
  have ha : a = θ := by
    by_contra h
    rw [if_neg h] at hpos
    linarith
  rw [if_neg]
  rw [ha]
  exact hne

theorem indicatorClass_cover [NeZero m] (a : Fin m) :
    0 < mixture (fun _ => (Fintype.card (Fin m) : ℝ)⁻¹) (indicatorClass m) a := by
  have hm : 0 < m := Nat.pos_of_ne_zero (NeZero.ne m)
  have hcard : (0:ℝ) < Fintype.card (Fin m) := by
    simp only [Fintype.card_fin]
    exact_mod_cast hm
  refine mixture_pos (θ₀ := a) (a := a) (fun _ => by positivity)
    (fun θ => indicatorClass_isPMF θ) (by positivity) ?_
  simp [indicatorClass]

/-- **Non-vacuity of the exact price theorem.** The `m` deterministic sources on
`m` letters satisfy all its hypotheses, and the price of universality for them is
`log₂ m` up to one bit. -/
theorem indicatorClass_sandwich [NeZero m] :
    (∀ L : Fin m → ℕ, IsCode L →
        ∃ θ, logb 2 (Fintype.card (Fin m)) ≤ redundancy (indicatorClass m θ) L) ∧
    (∃ L : Fin m → ℕ, IsCode L ∧
        ∀ θ, redundancy (indicatorClass m θ) L ≤ logb 2 (Fintype.card (Fin m)) + 1) :=
  price_of_universality_sandwich (fun θ => indicatorClass_isPMF θ)
    indicatorClass_disjoint (fun a => indicatorClass_cover a)

/-- The redundancy of a code on a deterministic source is just the length it
assigns to the certain message (the entropy is zero). -/
theorem redundancy_indicatorClass (θ : Fin m) (L : Fin m → ℕ) :
    redundancy (indicatorClass m θ) L = (L θ : ℝ) := by
  have hexp : expLen (indicatorClass m θ) L = (L θ : ℝ) := by
    rw [expLen]
    rw [Finset.sum_eq_single θ]
    · simp [indicatorClass]
    · intro b _ hb
      simp [indicatorClass, hb]
    · intro h; exact absurd (mem_univ θ) h
  have hent : entropy (indicatorClass m θ) = 0 := by
    rw [entropy]
    refine Finset.sum_eq_zero fun a _ => ?_
    by_cases h : a = θ <;> simp [indicatorClass, h]
  rw [redundancy, hexp, hent, sub_zero]

/-- **A sharp pigeonhole bound for code lengths.** Every Kraft code on `m`
messages gives some message a length of at least `log₂ m` bits — the exact price
of serving `m` mutually exclusive possibilities with one shared decoder. -/
theorem exists_length_ge_logb_card [NeZero m] (L : Fin m → ℕ) (hL : IsCode L) :
    ∃ θ : Fin m, logb 2 m ≤ (L θ : ℝ) := by
  obtain ⟨θ, hθ⟩ := indicatorClass_sandwich.1 L hL
  refine ⟨θ, ?_⟩
  rw [redundancy_indicatorClass] at hθ
  simpa using hθ

/-- A *specialised* decoder for one member of the class: it spends one bit on the
message its source actually emits. -/
theorem specialisation_code [NeZero m] (θ : Fin m) :
    ∃ L : Fin m → ℕ, IsCode L ∧ redundancy (indicatorClass m θ) L ≤ 1 := by
  classical
  refine ⟨fun a => if a = θ then 1 else m + 1, ?_, ?_⟩
  · have hsum : kraftSum (fun a : Fin m => if a = θ then 1 else m + 1)
        = ((2:ℝ)⁻¹) ^ 1 + ∑ _a ∈ univ.erase θ, ((2:ℝ)⁻¹) ^ (m + 1) := by
      rw [kraftSum, ← Finset.add_sum_erase _ _ (mem_univ θ)]
      congr 1
      · simp
      · exact Finset.sum_congr rfl fun a ha => by
          rw [if_neg (Finset.ne_of_mem_erase ha)]
    have hcard : (univ.erase θ).card = m - 1 := by
      rw [Finset.card_erase_of_mem (mem_univ θ), Finset.card_univ, Fintype.card_fin]
    have hconst : ∑ _a ∈ univ.erase θ, ((2:ℝ)⁻¹) ^ (m + 1)
        = ((m - 1 : ℕ) : ℝ) * ((2:ℝ)⁻¹) ^ (m + 1) := by
      rw [Finset.sum_const, hcard, nsmul_eq_mul]
    have hmle : ((m - 1 : ℕ) : ℝ) ≤ (m : ℝ) := by
      have : (m - 1 : ℕ) ≤ m := Nat.sub_le _ _
      exact_mod_cast this
    have hpow : (m : ℝ) ≤ (2:ℝ) ^ m := by
      have : m < 2 ^ m := Nat.lt_two_pow_self
      exact_mod_cast this.le
    have h2m : (0:ℝ) < (2:ℝ) ^ m := by positivity
    have hkey : ((m - 1 : ℕ) : ℝ) * ((2:ℝ)⁻¹) ^ (m + 1) ≤ (2:ℝ)⁻¹ := by
      have hinv : ((2:ℝ)⁻¹) ^ (m + 1) = ((2:ℝ) ^ (m + 1))⁻¹ := by
        rw [inv_pow]
      rw [hinv, pow_succ]
      rw [mul_inv_le_iff₀ (by positivity)]
      have : (2:ℝ)⁻¹ * ((2:ℝ) ^ m * 2) = (2:ℝ) ^ m := by
        field_simp
      rw [this]
      linarith
    rw [IsCode, hsum, hconst]
    have : ((2:ℝ)⁻¹) ^ 1 = (2:ℝ)⁻¹ := pow_one _
    rw [this]
    linarith
  · rw [redundancy_indicatorClass]
    simp

/-- **The value of specialisation.** For the class of `m` deterministic sources:
a decoder specialised to a single member pays at most one bit, while every
universal decoder pays at least `log₂ m` bits on some member.  Specialisation is
worth exactly `log₂ m - 1` bits here, and this is the whole of the gain. -/
theorem price_of_specialisation [NeZero m] :
    (∀ θ : Fin m, ∃ L : Fin m → ℕ, IsCode L ∧ redundancy (indicatorClass m θ) L ≤ 1) ∧
    (∀ L : Fin m → ℕ, IsCode L →
      ∃ θ : Fin m, logb 2 m ≤ redundancy (indicatorClass m θ) L) := by
  refine ⟨fun θ => specialisation_code θ, fun L hL => ?_⟩
  obtain ⟨θ, hθ⟩ := exists_length_ge_logb_card L hL
  exact ⟨θ, by rw [redundancy_indicatorClass]; exact hθ⟩

/-! ## The Bernoulli class: matching upper bound of order `log n` -/

/-- The maximum likelihood of a string with `k` ones is attained on the grid. -/
lemma exists_eq_mlik (n k : ℕ) :
    ∃ j : Fin (n + 1), mlik n k = ((j : ℝ) / n) ^ k * (1 - (j : ℝ) / n) ^ (n - k) := by
  obtain ⟨j₀, -, h₀⟩ :=
    Finset.exists_max_image (univ : Finset (Fin (n + 1)))
      (fun j : Fin (n + 1) => ((j : ℝ) / n) ^ k * (1 - (j : ℝ) / n) ^ (n - k)) univ_nonempty
  exact ⟨j₀, le_antisymm
    ((Finset.sup'_le_iff univ_nonempty _).2 fun j _ => h₀ j (mem_univ j))
    (Finset.le_sup' (α := ℝ)
      (fun j : Fin (n + 1) => ((j : ℝ) / n) ^ k * (1 - (j : ℝ) / n) ^ (n - k))
      (mem_univ j₀))⟩

/-- **Upper bound on the Shtarkov sum of the memoryless binary class.** -/
theorem shtarkov_bernClass_le (n : ℕ) : shtarkov (bernClass n) ≤ (n : ℝ) + 1 := by
  rw [shtarkov_bernClass]
  have hterm : ∀ k ∈ range (n + 1), (n.choose k : ℝ) * mlik n k ≤ 1 := by
    intro k hk
    obtain ⟨j, hj⟩ := exists_eq_mlik n k
    rw [hj, bern_eq_binw]
    have h01 := grid_mem_Icc j
    have hle : binw n ((j : ℝ) / n) k ≤ ∑ i ∈ range (n + 1), binw n ((j : ℝ) / n) i :=
      Finset.single_le_sum (f := fun i => binw n ((j : ℝ) / n) i)
        (fun i _ => binw_nonneg h01.1 h01.2 n i) hk
    rw [binw_sum] at hle
    exact hle
  calc ∑ k ∈ range (n + 1), (n.choose k : ℝ) * mlik n k
      ≤ ∑ _k ∈ range (n + 1), (1:ℝ) := Finset.sum_le_sum hterm
    _ = (n : ℝ) + 1 := by
        rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul, mul_one]
        push_cast
        ring

/-- **Two-sided rate for the memoryless binary class.** The exact minimax regret
`log₂ S` of the class of memoryless binary sources of block length `n` lies
between `(1/2) log₂ n − 2` and `log₂ (n + 1)`. -/
theorem bernoulli_regret_two_sided (n : ℕ) (hn : 1 ≤ n) :
    (1/2) * logb 2 n - 2 ≤ logb 2 (shtarkov (bernClass n)) ∧
    logb 2 (shtarkov (bernClass n)) ≤ logb 2 ((n : ℝ) + 1) := by
  refine ⟨logb_shtarkov_bernClass_ge n hn, ?_⟩
  refine Real.logb_le_logb_of_le (by norm_num) ?_ (shtarkov_bernClass_le n)
  exact shtarkov_pos (bernClass_isPMF n)

/-- Achievability form of the upper bound: the NML code for the memoryless binary
class never loses more than a factor `n + 1` (i.e. `log₂ (n+1)` bits) against the
best member of the class, on any string. -/
theorem bernoulli_nml_le (n : ℕ) (j : Fin (n + 1)) (s : Msg n) :
    bernClass n j s ≤ ((n : ℝ) + 1) * nml (bernClass n) s := by
  refine le_trans (nml_regret_le (bernClass_isPMF n) j s) ?_
  have hnml : 0 ≤ nml (bernClass n) s := (nml_isPMF (bernClass_isPMF n)).nonneg s
  exact mul_le_mul_of_nonneg_right (shtarkov_bernClass_le n) hnml

end PriceOfUniversality