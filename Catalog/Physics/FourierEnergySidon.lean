/-
# Sidon sets: an exact computation of the Fourier energy `E`, and a quadratic gain

`Catalog.Physics.FourierEnergyBound` shows that the nonprincipal Fourier energy of
`FourierAdd.card_support_rep_ge` is `E = |G| Ẽ(A,B) − (|A||B|)²`, with `Ẽ` the additive
energy.  Here we compute `Ẽ`, hence `E`, hence the covering bound itself, for the two
extremal classes of sets on which the additive energy is *minimal*:

* **Sidon sets** (`IsSidon`): all sums `a + b` with `{a,b}` distinct unordered pairs are
  distinct.  Then `Ẽ(A,A) = 2k² − k` where `k = |A|`, so
  `E = |G|(2k² − k) − k⁴` and the covering bound equals `k³/(2k−1) ≥ k²/2`:
  a **quadratic** improvement on the pigeonhole bound `k`.

* **Exponent-two Sidon sets** (`IsSidon2`): in a group where `x + x = 0` no set can be
  Sidon (the whole diagonal collapses onto `0`), and the correct notion asks only that
  distinct unordered pairs of *distinct* elements have distinct sums.  Then
  `Ẽ(A,A) = 3k² − 2k`, `E = |G|(3k² − 2k) − k⁴`, and the bound equals
  `k³/(3k−2) ≥ k²/3` — still quadratic, but with the constant degraded from `1/2` to
  `1/3` by the diagonal collapse.  This is a genuinely characteristic-dependent
  phenomenon, quantified exactly.

Main results:

* `FourierEnergy.rep_sidon_offDiag`, `FourierEnergy.rep_sidon_diag` : the representation
  function of a Sidon set is `2` off the diagonal and `1` on it.
* `FourierEnergy.addEnergy_sidon`, `FourierEnergy.fourierEnergy_sidon` : `Ẽ = 2k² − k`
  and `E = |G|(2k² − k) − k⁴`.
* `FourierEnergy.fourierBound_sidon` : the covering bound equals `k³/(2k−1)`.
* `FourierEnergy.sidon_beats_pigeonhole` : it is *strictly* bigger than `k` as soon as
  `k ≥ 2`, and `FourierEnergy.sidon_quadratic` : it is at least `k²/2`.
* `FourierEnergy.addEnergy_sidon2`, `FourierEnergy.fourierEnergy_sidon2`,
  `FourierEnergy.fourierBound_sidon2`, `FourierEnergy.sidon2_beats_pigeonhole`,
  `FourierEnergy.sidon2_quadratic` : the exponent-two analogues.
* `FourierEnergy.isSidon2_of_triple` : a convenient triple-wise criterion for `IsSidon2`.
-/

import Mathlib
import Catalog.Physics.FourierEnergyBound

open Finset FourierFA FourierAdd
open scoped Pointwise

namespace FourierEnergy

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## Sidon sets -/

/-- `A` is a *Sidon set* (`B₂` set): the sum `a + b` determines the unordered pair
`{a, b}`. -/
def IsSidon (A : Finset G) : Prop :=
  ∀ a ∈ A, ∀ b ∈ A, ∀ c ∈ A, ∀ d ∈ A, a + b = c + d → (a = c ∧ b = d) ∨ (a = d ∧ b = c)

variable {A : Finset G}

omit [Fintype G] in
/-- On the diagonal, a Sidon set has exactly one representation. -/
theorem rep_sidon_diag (h : IsSidon A) {a : G} (ha : a ∈ A) : rep A A (a + a) = 1 := by
  have hfil : A.filter (fun y => a + a - y ∈ A) = {a} := by
    ext y
    simp only [Finset.mem_filter, Finset.mem_singleton]
    constructor
    · rintro ⟨hy, hz⟩
      have hsum : y + (a + a - y) = a + a := by abel
      rcases h y hy _ hz a ha a ha hsum with ⟨h1, _⟩ | ⟨h1, _⟩ <;> exact h1
    · rintro rfl
      exact ⟨ha, by simpa using ha⟩
  rw [rep, hfil, Finset.card_singleton]

omit [Fintype G] in
/-- Off the diagonal, a Sidon set has exactly two representations. -/
theorem rep_sidon_offDiag (h : IsSidon A) {a b : G} (ha : a ∈ A) (hb : b ∈ A)
    (hab : a ≠ b) : rep A A (a + b) = 2 := by
  have hfil : A.filter (fun y => a + b - y ∈ A) = {a, b} := by
    ext y
    simp only [Finset.mem_filter, Finset.mem_insert, Finset.mem_singleton]
    constructor
    · rintro ⟨hy, hz⟩
      have hsum : y + (a + b - y) = a + b := by abel
      rcases h y hy _ hz a ha b hb hsum with ⟨h1, _⟩ | ⟨h1, _⟩
      · exact Or.inl h1
      · exact Or.inr h1
    · rintro (rfl | rfl)
      · exact ⟨ha, by simpa using hb⟩
      · exact ⟨hb, by simpa using ha⟩
  rw [rep, hfil, Finset.card_pair hab]

/-- **Additive energy of a Sidon set**: `Ẽ(A,A) = 2|A|² − |A|`. -/
theorem addEnergy_sidon (h : IsSidon A) : addEnergy A A + A.card = 2 * A.card ^ 2 := by
  classical
  rw [sum_rep_sq_eq_sum_over_pairs, ← Finset.diag_union_offDiag A,
    Finset.sum_union (Finset.disjoint_diag_offDiag A)]
  have hd : ∑ p ∈ A.diag, rep A A (p.1 + p.2) = A.card := by
    rw [Finset.sum_congr rfl (fun p hp => ?_), Finset.sum_const, Finset.diag_card,
      smul_eq_mul, mul_one]
    obtain ⟨hp1, hp2⟩ := Finset.mem_diag.1 hp
    rw [← hp2]
    exact rep_sidon_diag h hp1
  have ho : ∑ p ∈ A.offDiag, rep A A (p.1 + p.2) = 2 * (A.card * A.card - A.card) := by
    rw [Finset.sum_congr rfl (fun p hp => ?_), Finset.sum_const, Finset.offDiag_card,
      smul_eq_mul, mul_comm]
    obtain ⟨hp1, hp2, hp3⟩ := Finset.mem_offDiag.1 hp
    exact rep_sidon_offDiag h hp1 hp2 hp3
  rw [hd, ho]
  have hsq : A.card ^ 2 = A.card * A.card := sq A.card
  rcases Nat.eq_zero_or_pos A.card with h0 | h0
  · simp [h0]
  · have hle : A.card ≤ A.card * A.card := Nat.le_mul_of_pos_left _ h0
    omega

/-- The additive energy of a Sidon set, over the reals. -/
theorem addEnergy_sidon_real (h : IsSidon A) :
    (addEnergy A A : ℝ) = 2 * (A.card : ℝ) ^ 2 - (A.card : ℝ) := by
  have := addEnergy_sidon h
  have : ((addEnergy A A + A.card : ℕ) : ℝ) = ((2 * A.card ^ 2 : ℕ) : ℝ) := by
    exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) this
  push_cast at this
  linarith

/-- **The nonprincipal Fourier energy of a Sidon set**: `E = |G|(2k² − k) − k⁴`. -/
theorem fourierEnergy_sidon (h : IsSidon A) :
    fourierEnergy A A
      = (Fintype.card G : ℝ) * (2 * (A.card : ℝ) ^ 2 - (A.card : ℝ)) - (A.card : ℝ) ^ 4 := by
  rw [fourierEnergy_eq, addEnergy_sidon_real h]
  ring

/-- **The covering bound for a Sidon set** equals `k³/(2k−1)`. -/
theorem fourierBound_sidon (h : IsSidon A) (hA : A.Nonempty) :
    fourierBound A A = (A.card : ℝ) ^ 3 / (2 * (A.card : ℝ) - 1) := by
  have hk : (1 : ℝ) ≤ (A.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hA
  have hk0 : (0 : ℝ) < (A.card : ℝ) := by linarith
  have hden : (0 : ℝ) < 2 * (A.card : ℝ) - 1 := by linarith
  rw [fourierBound_eq_addEnergy_ratio A A hA hA, addEnergy_sidon_real h]
  rw [div_eq_div_iff (by nlinarith) (ne_of_gt hden)]
  ring

/-- **Sidon sets beat pigeonhole**: for `|A| ≥ 2` the covering bound is strictly larger
than the pigeonhole bound `max(|A|,|A|) = |A|`. -/
theorem sidon_beats_pigeonhole (h : IsSidon A) (hk : 2 ≤ A.card) :
    ((max A.card A.card : ℕ) : ℝ) < fourierBound A A := by
  have hA : A.Nonempty := Finset.card_pos.1 (by omega)
  have hk' : (2 : ℝ) ≤ (A.card : ℝ) := by exact_mod_cast hk
  have hden : (0 : ℝ) < 2 * (A.card : ℝ) - 1 := by linarith
  rw [fourierBound_sidon h hA, max_self, lt_div_iff₀ hden]
  have hk0 : (0 : ℝ) < (A.card : ℝ) := by linarith
  have h1 : (0 : ℝ) < (A.card : ℝ) - 1 := by linarith
  nlinarith [mul_pos hk0 (mul_pos h1 h1)]

/-- **Quadratic gain**: the covering bound for a Sidon set is at least `|A|²/2`, whereas
pigeonhole only gives `|A|`. -/
theorem sidon_quadratic (h : IsSidon A) (hA : A.Nonempty) :
    (A.card : ℝ) ^ 2 / 2 ≤ fourierBound A A := by
  have hk : (1 : ℝ) ≤ (A.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hA
  have hden : (0 : ℝ) < 2 * (A.card : ℝ) - 1 := by linarith
  rw [fourierBound_sidon h hA, le_div_iff₀ hden]
  nlinarith [sq_nonneg ((A.card : ℝ))]

/-- The resulting sumset bound: a Sidon set has `|A + A| ≥ |A|²/2`. -/
theorem card_add_ge_sidon (h : IsSidon A) (hA : A.Nonempty) :
    (A.card : ℝ) ^ 2 / 2 ≤ (((A + A).card : ℕ) : ℝ) := by
  refine le_trans (sidon_quadratic h hA) ?_
  rw [fourierBound_eq_addEnergy_ratio A A hA hA]
  exact card_add_ge_addEnergy_ratio A A hA hA

/-! ## Exponent two: Sidon sets modulo the collapsed diagonal -/

/-- `A` is *Sidon off the diagonal*: the sum of two **distinct** elements determines the
unordered pair.  In a group of exponent two this is the strongest possible Sidon-type
condition, since `a + a = 0` for every `a`. -/
def IsSidon2 (A : Finset G) : Prop :=
  ∀ a ∈ A, ∀ b ∈ A, ∀ c ∈ A, ∀ d ∈ A, a ≠ b → c ≠ d → a + b = c + d →
    (a = c ∧ b = d) ∨ (a = d ∧ b = c)

omit [Fintype G] [DecidableEq G] in
/-- A convenient triple-wise criterion: in a group of exponent two, `A` is Sidon off the
diagonal as soon as `a + b + y ∉ A` for all triples of elements with `a ≠ b`,
`y ∉ {a, b}`. -/
theorem isSidon2_of_triple (hexp : ∀ x : G, x + x = 0)
    (h3 : ∀ a ∈ A, ∀ b ∈ A, ∀ y ∈ A, a ≠ b → y ≠ a → y ≠ b → a + b + y ∉ A) :
    IsSidon2 A := by
  intro a ha b hb c hc d hd hab hcd habcd
  by_cases hca : c = a
  · subst hca
    left
    refine ⟨rfl, ?_⟩
    have : c + b = c + d := habcd
    exact add_left_cancel this
  · by_cases hcb : c = b
    · subst hcb
      right
      refine ⟨?_, rfl⟩
      have h1 : c + a = c + d := by rw [add_comm c a]; exact habcd
      exact add_left_cancel h1
    · exfalso
      refine h3 a ha b hb c hc hab hca hcb ?_
      rw [habcd]
      have : c + d + c = d + (c + c) := by abel
      rw [this, hexp c, add_zero]
      exact hd

omit [Fintype G] in
/-- In a group of exponent two the diagonal of `A` contributes `|A|` representations
of `0`. -/
theorem rep_exp2_zero (hexp : ∀ x : G, x + x = 0) (A : Finset G) :
    rep A A 0 = A.card := by
  have hfil : A.filter (fun y => (0 : G) - y ∈ A) = A := by
    refine Finset.filter_true_of_mem fun y hy => ?_
    have hneg : (0 : G) - y = y := by
      rw [zero_sub, neg_eq_of_add_eq_zero_left (hexp y)]
    rwa [hneg]
  rw [rep, hfil]

omit [Fintype G] in
/-- Off the diagonal, an exponent-two Sidon set has exactly two representations. -/
theorem rep_sidon2_offDiag (hexp : ∀ x : G, x + x = 0) (h : IsSidon2 A) {a b : G}
    (ha : a ∈ A) (hb : b ∈ A) (hab : a ≠ b) : rep A A (a + b) = 2 := by
  have hfil : A.filter (fun y => a + b - y ∈ A) = {a, b} := by
    ext y
    simp only [Finset.mem_filter, Finset.mem_insert, Finset.mem_singleton]
    constructor
    · rintro ⟨hy, hz⟩
      have hsum : y + (a + b - y) = a + b := by abel
      have hne : y ≠ a + b - y := by
        intro hcon
        apply hab
        have hyy : y + y = a + b := by
          nth_rewrite 2 [hcon]
          abel
        have h0 : a + b = 0 := by rw [← hyy, hexp y]
        have h1 : -b = a := neg_eq_of_add_eq_zero_left h0
        have h2 : -b = b := neg_eq_of_add_eq_zero_left (hexp b)
        rw [← h1, h2]
      rcases h y hy _ hz a ha b hb hne hab hsum with ⟨h1, _⟩ | ⟨h1, _⟩
      · exact Or.inl h1
      · exact Or.inr h1
    · rintro (rfl | rfl)
      · exact ⟨ha, by simpa using hb⟩
      · exact ⟨hb, by simpa using ha⟩
  rw [rep, hfil, Finset.card_pair hab]

/-- **Additive energy of an exponent-two Sidon set**: `Ẽ(A,A) = 3k² − 2k`. -/
theorem addEnergy_sidon2 (hexp : ∀ x : G, x + x = 0) (h : IsSidon2 A) :
    addEnergy A A + 2 * A.card = 3 * A.card ^ 2 := by
  classical
  rw [sum_rep_sq_eq_sum_over_pairs, ← Finset.diag_union_offDiag A,
    Finset.sum_union (Finset.disjoint_diag_offDiag A)]
  have hd : ∑ p ∈ A.diag, rep A A (p.1 + p.2) = A.card * A.card := by
    rw [Finset.sum_congr rfl (fun p hp => ?_), Finset.sum_const, Finset.diag_card,
      smul_eq_mul]
    obtain ⟨hp1, hp2⟩ := Finset.mem_diag.1 hp
    rw [← hp2, hexp p.1]
    exact rep_exp2_zero hexp A
  have ho : ∑ p ∈ A.offDiag, rep A A (p.1 + p.2) = 2 * (A.card * A.card - A.card) := by
    rw [Finset.sum_congr rfl (fun p hp => ?_), Finset.sum_const, Finset.offDiag_card,
      smul_eq_mul, mul_comm]
    obtain ⟨hp1, hp2, hp3⟩ := Finset.mem_offDiag.1 hp
    exact rep_sidon2_offDiag hexp h hp1 hp2 hp3
  rw [hd, ho]
  have hsq : A.card ^ 2 = A.card * A.card := sq A.card
  rcases Nat.eq_zero_or_pos A.card with h0 | h0
  · simp [h0]
  · have hle : A.card ≤ A.card * A.card := Nat.le_mul_of_pos_left _ h0
    omega

/-- The additive energy of an exponent-two Sidon set, over the reals. -/
theorem addEnergy_sidon2_real (hexp : ∀ x : G, x + x = 0) (h : IsSidon2 A) :
    (addEnergy A A : ℝ) = 3 * (A.card : ℝ) ^ 2 - 2 * (A.card : ℝ) := by
  have h1 := addEnergy_sidon2 hexp h
  have h2 : ((addEnergy A A + 2 * A.card : ℕ) : ℝ) = ((3 * A.card ^ 2 : ℕ) : ℝ) := by
    exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) h1
  push_cast at h2
  linarith

/-- **The nonprincipal Fourier energy of an exponent-two Sidon set**:
`E = |G|(3k² − 2k) − k⁴`. -/
theorem fourierEnergy_sidon2 (hexp : ∀ x : G, x + x = 0) (h : IsSidon2 A) :
    fourierEnergy A A
      = (Fintype.card G : ℝ) * (3 * (A.card : ℝ) ^ 2 - 2 * (A.card : ℝ))
        - (A.card : ℝ) ^ 4 := by
  rw [fourierEnergy_eq, addEnergy_sidon2_real hexp h]
  ring

/-- **The covering bound for an exponent-two Sidon set** equals `k³/(3k−2)`. -/
theorem fourierBound_sidon2 (hexp : ∀ x : G, x + x = 0) (h : IsSidon2 A) (hA : A.Nonempty) :
    fourierBound A A = (A.card : ℝ) ^ 3 / (3 * (A.card : ℝ) - 2) := by
  have hk : (1 : ℝ) ≤ (A.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hA
  have hden : (0 : ℝ) < 3 * (A.card : ℝ) - 2 := by linarith
  rw [fourierBound_eq_addEnergy_ratio A A hA hA, addEnergy_sidon2_real hexp h]
  rw [div_eq_div_iff (by nlinarith) (ne_of_gt hden)]
  ring

/-- **Exponent-two Sidon sets beat pigeonhole** as soon as `|A| ≥ 3` (for `|A| ≤ 2` the
bound coincides with pigeonhole). -/
theorem sidon2_beats_pigeonhole (hexp : ∀ x : G, x + x = 0) (h : IsSidon2 A)
    (hk : 3 ≤ A.card) : ((max A.card A.card : ℕ) : ℝ) < fourierBound A A := by
  have hA : A.Nonempty := Finset.card_pos.1 (by omega)
  have hk' : (3 : ℝ) ≤ (A.card : ℝ) := by exact_mod_cast hk
  have hden : (0 : ℝ) < 3 * (A.card : ℝ) - 2 := by linarith
  rw [fourierBound_sidon2 hexp h hA, max_self, lt_div_iff₀ hden]
  have hk0 : (0 : ℝ) < (A.card : ℝ) := by linarith
  have h1 : (0 : ℝ) < (A.card : ℝ) - 1 := by linarith
  have h2 : (0 : ℝ) < (A.card : ℝ) - 2 := by linarith
  nlinarith [mul_pos hk0 (mul_pos h1 h2)]

/-- **Quadratic gain in exponent two**, with the constant degraded to `1/3`. -/
theorem sidon2_quadratic (hexp : ∀ x : G, x + x = 0) (h : IsSidon2 A) (hA : A.Nonempty) :
    (A.card : ℝ) ^ 2 / 3 ≤ fourierBound A A := by
  have hk : (1 : ℝ) ≤ (A.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hA
  have hden : (0 : ℝ) < 3 * (A.card : ℝ) - 2 := by linarith
  rw [fourierBound_sidon2 hexp h hA, le_div_iff₀ hden]
  nlinarith [sq_nonneg ((A.card : ℝ))]

/-- The resulting sumset bound in exponent two: `|A + A| ≥ |A|²/3`. -/
theorem card_add_ge_sidon2 (hexp : ∀ x : G, x + x = 0) (h : IsSidon2 A) (hA : A.Nonempty) :
    (A.card : ℝ) ^ 2 / 3 ≤ (((A + A).card : ℕ) : ℝ) := by
  refine le_trans (sidon2_quadratic hexp h hA) ?_
  rw [fourierBound_eq_addEnergy_ratio A A hA hA]
  exact card_add_ge_addEnergy_ratio A A hA hA

/-! ## How sharp is the bound?  Exact sumset sizes -/

/-- **The exact sumset size of a Sidon set**: `|A + A| = k(k+1)/2`.  (Stated without
division.)  The proof is a second-moment count: on the support the representation
function takes only the values `1` and `2`, so it satisfies `r² + 2 = 3r` there. -/
theorem card_add_sidon_eq (h : IsSidon A) :
    2 * (A + A).card = A.card * (A.card + 1) := by
  have hkey : ∀ c ∈ A + A, rep A A c ^ 2 + 2 = 3 * rep A A c := by
    intro c hc
    obtain ⟨a, ha, b, hb, rfl⟩ := Finset.mem_add.1 hc
    by_cases hab : a = b
    · subst hab
      rw [rep_sidon_diag h ha]
      norm_num
    · rw [rep_sidon_offDiag h ha hb hab]
      norm_num
  have h2 : ∑ c ∈ A + A, (rep A A c ^ 2 + 2) = ∑ c ∈ A + A, 3 * rep A A c :=
    Finset.sum_congr rfl hkey
  rw [Finset.sum_add_distrib, Finset.sum_const, smul_eq_mul, ← Finset.mul_sum,
    sum_rep_sq_support, sum_rep_support] at h2
  have h3 := addEnergy_sidon h
  have hsq : A.card ^ 2 = A.card * A.card := sq A.card
  have hmul : A.card * (A.card + 1) = A.card * A.card + A.card := by ring
  omega

/-- **The Sidon bound is asymptotically sharp**: the covering bound underestimates the
true sumset size by a factor of at most `1 + 1/(2k)`. -/
theorem sidon_bound_sharp (h : IsSidon A) (hA : A.Nonempty) :
    (((A + A).card : ℕ) : ℝ) ≤ (1 + 1 / (2 * (A.card : ℝ))) * fourierBound A A := by
  have hk : (1 : ℝ) ≤ (A.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hA
  have hden : (0 : ℝ) < 2 * (A.card : ℝ) - 1 := by linarith
  have hcard : 2 * (((A + A).card : ℕ) : ℝ) = (A.card : ℝ) * ((A.card : ℝ) + 1) := by
    have := card_add_sidon_eq h
    have hc : ((2 * (A + A).card : ℕ) : ℝ) = ((A.card * (A.card + 1) : ℕ) : ℝ) := by
      exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) this
    push_cast at hc
    linarith
  have hk0 : (0 : ℝ) < (A.card : ℝ) := by linarith
  have key : (1 + 1 / (2 * (A.card : ℝ))) * ((A.card : ℝ) ^ 3 / (2 * (A.card : ℝ) - 1))
      = (A.card : ℝ) ^ 2 * (2 * (A.card : ℝ) + 1) / (2 * (2 * (A.card : ℝ) - 1)) := by
    field_simp
  rw [fourierBound_sidon h hA, key, le_div_iff₀ (by linarith)]
  nlinarith [hcard, hk]

/-- **The exact sumset size of an exponent-two Sidon set**: `2|A + A| + k = k² + 2`, i.e.
`|A + A| = 1 + k(k−1)/2`; the extra `1` is the collapsed diagonal `{0}`. -/
theorem card_add_sidon2_eq (hexp : ∀ x : G, x + x = 0) (h : IsSidon2 A) (hA : A.Nonempty) :
    2 * (A + A).card + A.card = A.card ^ 2 + 2 := by
  classical
  obtain ⟨a₀, ha₀⟩ := hA
  have hzero : (0 : G) ∈ A + A := by
    refine Finset.mem_add.2 ⟨a₀, ha₀, a₀, ha₀, hexp a₀⟩
  have hsplit : ∑ c ∈ A + A, rep A A c
      = rep A A 0 + ∑ c ∈ (A + A).erase 0, rep A A c :=
    (Finset.add_sum_erase _ _ hzero).symm
  have hres : ∀ c ∈ (A + A).erase 0, rep A A c = 2 := by
    intro c hc
    obtain ⟨hc0, hcmem⟩ := Finset.mem_erase.1 hc
    obtain ⟨a, ha, b, hb, rfl⟩ := Finset.mem_add.1 hcmem
    have hab : a ≠ b := by
      rintro rfl
      exact hc0 (hexp a)
    exact rep_sidon2_offDiag hexp h ha hb hab
  rw [Finset.sum_congr rfl hres, Finset.sum_const, smul_eq_mul,
    rep_exp2_zero hexp A, sum_rep_support] at hsplit
  have hcard : (A + A).card = ((A + A).erase 0).card + 1 :=
    (Finset.card_erase_add_one hzero).symm
  have hsq : A.card ^ 2 = A.card * A.card := sq A.card
  omega

/-- **In exponent two the bound is off by a factor at most `3/2`** — and asymptotically
exactly `3/2`, the price of the collapsed diagonal. -/
theorem sidon2_bound_within_three_halves (hexp : ∀ x : G, x + x = 0) (h : IsSidon2 A)
    (hA : A.Nonempty) :
    (((A + A).card : ℕ) : ℝ) ≤ 3 / 2 * fourierBound A A := by
  have hk : (1 : ℝ) ≤ (A.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hA
  have hden : (0 : ℝ) < 3 * (A.card : ℝ) - 2 := by linarith
  have hcard : 2 * (((A + A).card : ℕ) : ℝ) + (A.card : ℝ) = (A.card : ℝ) ^ 2 + 2 := by
    have hc := card_add_sidon2_eq hexp h hA
    have hc' : ((2 * (A + A).card + A.card : ℕ) : ℝ) = ((A.card ^ 2 + 2 : ℕ) : ℝ) := by
      exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) hc
    push_cast at hc'
    linarith
  have key : 3 / 2 * ((A.card : ℝ) ^ 3 / (3 * (A.card : ℝ) - 2))
      = 3 * (A.card : ℝ) ^ 3 / (2 * (3 * (A.card : ℝ) - 2)) := by
    field_simp
  rw [fourierBound_sidon2 hexp h hA, key, le_div_iff₀ (by linarith)]
  nlinarith [hcard, hk, sq_nonneg (5 * (A.card : ℝ) - 4)]

end FourierEnergy