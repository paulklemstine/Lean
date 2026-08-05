import Mathlib
import Combinatorics.RamseyExponentialBounds

/-!
# The two-parameter normalization needs an upper bound on the base

This file settles conjecture **FD5** of the research thread on exponential bounds
for diagonal Ramsey numbers.

For off-diagonal (asymmetric) Ramsey estimates one compares a two-parameter
quantity `R s t` with a *variable* base `β s t` raised to the power `s + t`.
There are two natural ways to record a saving:

* `RamseyBounds.HasProportionalSaving₂ R β S` : a fixed `q ∈ (0,1)` with
  `R s t ≤ (q · β s t)^(s+t)` on the parameter set `S`;
* `RamseyBounds.HasAdditiveGap₂ R β S` : a fixed `ε > 0` with
  `R s t ≤ (β s t - ε)^(s+t)` on `S`, the reduced base staying positive.

`RamseyBounds.additiveGap₂_of_proportionalSaving₂` shows that a *positive lower
bound* `m ≤ β` suffices for one implication, and
`RamseyBounds.proportionalSaving₂_iff_additiveGap₂` records the equivalence when
`β` is also bounded above by `M`.

The main result `RamseyBounds.additiveGap₂_not_imp_proportionalSaving₂` proves
FD5: the upper bound cannot be dropped.  The explicit witness is

  `R s t = (s+t+1)^(s+t)`,  `β s t = (s+t) + 2`,  `S = univ`,

for which the additive gap holds with `ε = 1` while every proportional saving
fails at all sufficiently large `s + t`.
-/

namespace RamseyBounds

/-- A fixed proportional saving against a variable base, on a parameter set. -/
def HasProportionalSaving₂ (R : ℕ → ℕ → ℕ) (β : ℕ → ℕ → ℝ)
    (S : Set (ℕ × ℕ)) : Prop :=
  ∃ q : ℝ, 0 < q ∧ q < 1 ∧
    ∀ p ∈ S, (R p.1 p.2 : ℝ) ≤ (q * β p.1 p.2) ^ (p.1 + p.2)

/-- A fixed additive gap below a variable base, on a parameter set.  The reduced
base is required to remain positive, which is what makes the estimate a genuine
exponential improvement rather than a sign artefact. -/
def HasAdditiveGap₂ (R : ℕ → ℕ → ℕ) (β : ℕ → ℕ → ℝ)
    (S : Set (ℕ × ℕ)) : Prop :=
  ∃ ε : ℝ, 0 < ε ∧ (∀ p ∈ S, 0 < β p.1 p.2 - ε) ∧
    ∀ p ∈ S, (R p.1 p.2 : ℝ) ≤ (β p.1 p.2 - ε) ^ (p.1 + p.2)

/-! ### The easy direction: only a positive lower bound is needed -/

/-- A proportional saving always yields an additive gap, using only a positive
lower bound `m` for the base. -/
theorem additiveGap₂_of_proportionalSaving₂ {R : ℕ → ℕ → ℕ} {β : ℕ → ℕ → ℝ}
    {S : Set (ℕ × ℕ)} {m : ℝ} (hm : 0 < m) (hlb : ∀ p ∈ S, m ≤ β p.1 p.2)
    (h : HasProportionalSaving₂ R β S) : HasAdditiveGap₂ R β S := by
  obtain ⟨q, hq0, hq1, hbd⟩ := h
  refine ⟨(1 - q) * m, mul_pos (by linarith) hm, ?_, ?_⟩
  · intro p hp
    have hβ := hlb p hp
    nlinarith [hβ]
  · intro p hp
    have hβ := hlb p hp
    have hkey : q * β p.1 p.2 ≤ β p.1 p.2 - (1 - q) * m := by nlinarith
    refine le_trans (hbd p hp) ?_
    exact pow_le_pow_left₀ (mul_nonneg hq0.le (by linarith)) hkey _

/-! ### The hard direction, under a two-sided bound -/

/-- With a two-sided bound `m ≤ β ≤ M` (and `m > 0`) the additive gap can be
converted back into a proportional saving. -/
theorem proportionalSaving₂_of_additiveGap₂ {R : ℕ → ℕ → ℕ} {β : ℕ → ℕ → ℝ}
    {S : Set (ℕ × ℕ)} {M : ℝ} (hM : 0 < M) (hub : ∀ p ∈ S, β p.1 p.2 ≤ M)
    (h : HasAdditiveGap₂ R β S) : HasProportionalSaving₂ R β S := by
  obtain ⟨ε, hε, hpos, hbd⟩ := h
  refine ⟨max (1 - ε / M) (1 / 2), lt_of_lt_of_le (by norm_num) (le_max_right _ _),
    max_lt (by have := div_pos hε hM; linarith) (by norm_num), ?_⟩
  intro p hp
  have hp1 := hpos p hp
  have hp2 := hub p hp
  have hβpos : 0 < β p.1 p.2 := by linarith
  have hεM : ε < M := by linarith
  have hkey : β p.1 p.2 - ε ≤ max (1 - ε / M) (1 / 2) * β p.1 p.2 := by
    refine le_trans ?_ (mul_le_mul_of_nonneg_right (le_max_left _ _) hβpos.le)
    have h1 : (1 - ε / M) * β p.1 p.2 = β p.1 p.2 - (ε / M) * β p.1 p.2 := by ring
    rw [h1]
    have : (ε / M) * β p.1 p.2 ≤ ε := by
      rw [div_mul_eq_mul_div, div_le_iff₀ hM]
      nlinarith
    linarith
  exact le_trans (hbd p hp) (pow_le_pow_left₀ (by linarith) hkey _)

/-- The two-parameter normalization theorem under a two-sided bound on the
base. -/
theorem proportionalSaving₂_iff_additiveGap₂ {R : ℕ → ℕ → ℕ} {β : ℕ → ℕ → ℝ}
    {S : Set (ℕ × ℕ)} {m M : ℝ} (hm : 0 < m) (hM : 0 < M)
    (hlb : ∀ p ∈ S, m ≤ β p.1 p.2) (hub : ∀ p ∈ S, β p.1 p.2 ≤ M) :
    HasProportionalSaving₂ R β S ↔ HasAdditiveGap₂ R β S :=
  ⟨additiveGap₂_of_proportionalSaving₂ hm hlb,
    proportionalSaving₂_of_additiveGap₂ hM hub⟩

/-! ### FD5: the upper bound cannot be dropped -/

/-- The witnessing two-parameter quantity. -/
def fdR (s t : ℕ) : ℕ := (s + t + 1) ^ (s + t)

/-- The witnessing (unbounded) base. -/
def fdBase (s t : ℕ) : ℝ := (s + t : ℕ) + 2

theorem fdBase_ge_one (s t : ℕ) : 1 ≤ fdBase s t := by
  unfold fdBase
  have : (0 : ℝ) ≤ ((s + t : ℕ) : ℝ) := Nat.cast_nonneg _
  linarith

/-- The base is unbounded above on the whole parameter set. -/
theorem fdBase_unbounded (M : ℝ) : ∃ p : ℕ × ℕ, M < fdBase p.1 p.2 := by
  obtain ⟨n, hn⟩ := exists_nat_gt M
  refine ⟨(n, 0), ?_⟩
  unfold fdBase
  push_cast
  linarith

/-- The additive gap holds for the witness, with `ε = 1`. -/
theorem fd_hasAdditiveGap₂ :
    HasAdditiveGap₂ fdR fdBase Set.univ := by
  refine ⟨1, by norm_num, ?_, ?_⟩
  · intro p _
    unfold fdBase
    have : (0 : ℝ) ≤ ((p.1 + p.2 : ℕ) : ℝ) := Nat.cast_nonneg _
    linarith
  · intro p _
    unfold fdR fdBase
    push_cast
    ring_nf
    rfl

/-- No proportional saving holds for the witness. -/
theorem fd_not_hasProportionalSaving₂ :
    ¬ HasProportionalSaving₂ fdR fdBase Set.univ := by
  rintro ⟨q, hq0, hq1, hbd⟩
  -- pick `n` large enough that `n (1-q) ≥ 1`
  obtain ⟨n0, hn0⟩ := exists_nat_gt (1 / (1 - q))
  set n : ℕ := n0 + 1 with hn
  have hn1 : 1 ≤ n := by omega
  have hnR : (1 : ℝ) / (1 - q) < (n : ℝ) := by
    have : (n0 : ℝ) < (n : ℝ) := by exact_mod_cast Nat.lt_succ_self n0
    linarith
  have hqlt : 1 - q > 0 := by linarith
  have hkey : 1 < (n : ℝ) * (1 - q) := by
    rw [div_lt_iff₀ hqlt] at hnR
    linarith
  have h := hbd (n, 0) (Set.mem_univ _)
  simp only [fdR, fdBase] at h
  have hsum : (n : ℕ) + 0 = n := by omega
  rw [hsum] at h
  push_cast at h
  -- but `n+1 > q (n+2)`, contradicting the bound raised to the power `n`
  have hbase : q * ((n : ℝ) + 2) < (n : ℝ) + 1 := by nlinarith
  have hlt : (q * ((n : ℝ) + 2)) ^ n < ((n : ℝ) + 1) ^ n :=
    pow_lt_pow_left₀ hbase (by positivity) (by omega)
  linarith

/-- **FD5.**  Without an upper bound on the base, the additive-gap formulation
is strictly weaker than the proportional-saving formulation: there is a
two-parameter quantity `R`, a base `β ≥ 1` unbounded above on the parameter set,
such that `HasAdditiveGap₂ R β S` holds while `HasProportionalSaving₂ R β S`
fails.  Hence the hypothesis `β ≤ M` in `proportionalSaving₂_of_additiveGap₂`
cannot be removed. -/
theorem additiveGap₂_not_imp_proportionalSaving₂ :
    ∃ (R : ℕ → ℕ → ℕ) (β : ℕ → ℕ → ℝ) (S : Set (ℕ × ℕ)),
      (∀ p ∈ S, 1 ≤ β p.1 p.2) ∧
      (∀ M : ℝ, ∃ p ∈ S, M < β p.1 p.2) ∧
      HasAdditiveGap₂ R β S ∧ ¬ HasProportionalSaving₂ R β S :=
  ⟨fdR, fdBase, Set.univ, fun p _ => fdBase_ge_one p.1 p.2,
    fun M => by
      obtain ⟨p, hp⟩ := fdBase_unbounded M
      exact ⟨p, Set.mem_univ _, hp⟩,
    fd_hasAdditiveGap₂, fd_not_hasProportionalSaving₂⟩

end RamseyBounds