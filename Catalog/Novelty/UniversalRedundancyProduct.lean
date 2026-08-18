/-
# The price of universality, V: additivity over independent components

The minimax regret of a class of sources was computed exactly in
`UniversalRedundancyShtarkov.lean` as `log₂ S`, `S` the Shtarkov sum.  Here we
show that the Shtarkov sum is **multiplicative** over independent products of
classes,

  `S(P ⊗ Q) = S(P) · S(Q)`,

so that the price of universality is **additive**:

  `regret(P ⊗ Q) = regret(P) + regret(Q)`.

Together with the `(1/2) log₂ n` bound of `UniversalRedundancyBernoulli.lean`
this yields the `k`-parameter Rissanen rate: a class of `k` independent
memoryless binary blocks of length `n` forces every code to pay at least
`k · ((1/2) log₂ n − 2)` bits of regret.  We prove the case `k = 2` explicitly
(`two_block_bernoulli_regret`), which already exhibits the linear-in-`k` growth
that makes the price of universality unbounded as models get richer.

The structural moral for the research programme: *the shared decompressor must
carry one independent "parameter description" per independent component of the
model class; specialisation buys back exactly that amount and no more.*
-/
import Novelty.UniversalRedundancyBernoulli

namespace PriceOfUniversality

open Finset Real

variable {A B : Type*} [Fintype A] [Fintype B] [Nonempty A] [Nonempty B]
variable {Θ Ψ : Type*} [Fintype Θ] [Fintype Ψ] [Nonempty Θ] [Nonempty Ψ]

/-- The independent product of two source classes: parameters and messages are
paired, and probabilities multiply. -/
noncomputable def prodClass (p : Θ → A → ℝ) (q : Ψ → B → ℝ) : Θ × Ψ → A × B → ℝ :=
  fun t x => p t.1 x.1 * q t.2 x.2

omit [Nonempty A] [Nonempty B] [Fintype Θ] [Fintype Ψ] [Nonempty Θ] [Nonempty Ψ] in
theorem prodClass_isPMF {p : Θ → A → ℝ} {q : Ψ → B → ℝ}
    (hp : ∀ θ, IsPMF (p θ)) (hq : ∀ ψ, IsPMF (q ψ)) (t : Θ × Ψ) :
    IsPMF (prodClass p q t) := by
  refine ⟨fun x => mul_nonneg ((hp t.1).nonneg x.1) ((hq t.2).nonneg x.2), ?_⟩
  rw [Fintype.sum_prod_type]
  calc ∑ a : A, ∑ b : B, p t.1 a * q t.2 b
      = ∑ a : A, p t.1 a * ∑ b : B, q t.2 b :=
        Finset.sum_congr rfl fun a _ => by rw [Finset.mul_sum]
    _ = (∑ a : A, p t.1 a) * 1 := by rw [(hq t.2).total, ← Finset.sum_mul]
    _ = 1 := by rw [(hp t.1).total, mul_one]

omit [Nonempty A] [Nonempty B] in
/-- The maximum likelihood of a product class factorises. -/
theorem maxLik_prodClass {p : Θ → A → ℝ} {q : Ψ → B → ℝ}
    (hp : ∀ θ, IsPMF (p θ)) (hq : ∀ ψ, IsPMF (q ψ)) (x : A × B) :
    maxLik (prodClass p q) x = maxLik p x.1 * maxLik q x.2 := by
  refine le_antisymm ?_ ?_
  · refine (Finset.sup'_le_iff univ_nonempty _).2 fun t _ => ?_
    exact mul_le_mul (le_maxLik p t.1 x.1) (le_maxLik q t.2 x.2)
      ((hq t.2).nonneg x.2) (maxLik_nonneg hp x.1)
  · obtain ⟨θ₀, hθ₀⟩ := exists_eq_maxLik p x.1
    obtain ⟨ψ₀, hψ₀⟩ := exists_eq_maxLik q x.2
    rw [hθ₀, hψ₀]
    exact Finset.le_sup' (α := ℝ) (fun t : Θ × Ψ => prodClass p q t x)
      (mem_univ ((θ₀, ψ₀) : Θ × Ψ))

omit [Nonempty A] [Nonempty B] in
/-- **The Shtarkov sum is multiplicative over independent products.** -/
theorem shtarkov_prodClass {p : Θ → A → ℝ} {q : Ψ → B → ℝ}
    (hp : ∀ θ, IsPMF (p θ)) (hq : ∀ ψ, IsPMF (q ψ)) :
    shtarkov (prodClass p q) = shtarkov p * shtarkov q := by
  rw [shtarkov, Fintype.sum_prod_type]
  calc ∑ a : A, ∑ b : B, maxLik (prodClass p q) (a, b)
      = ∑ a : A, ∑ b : B, maxLik p a * maxLik q b :=
        Finset.sum_congr rfl fun a _ =>
          Finset.sum_congr rfl fun b _ => maxLik_prodClass hp hq (a, b)
    _ = ∑ a : A, maxLik p a * ∑ b : B, maxLik q b :=
        Finset.sum_congr rfl fun a _ => by rw [Finset.mul_sum]
    _ = shtarkov p * shtarkov q := by rw [shtarkov, shtarkov, ← Finset.sum_mul]

omit [Nonempty A] [Nonempty B] in
/-- **The price of universality is additive over independent components.** -/
theorem logb_shtarkov_prodClass {p : Θ → A → ℝ} {q : Ψ → B → ℝ}
    (hp : ∀ θ, IsPMF (p θ)) (hq : ∀ ψ, IsPMF (q ψ)) :
    logb 2 (shtarkov (prodClass p q)) = logb 2 (shtarkov p) + logb 2 (shtarkov q) := by
  rw [shtarkov_prodClass hp hq]
  exact Real.logb_mul (ne_of_gt (shtarkov_pos hp)) (ne_of_gt (shtarkov_pos hq))

/-- Two independent memoryless binary blocks of length `n` force a regret of at
least `log₂ n − 4` bits: the `k = 2` case of Rissanen's `(k/2) log n` rate. -/
theorem two_block_bernoulli_regret (n : ℕ) (hn : 1 ≤ n)
    {L : Msg n × Msg n → ℕ} (hL : IsCode L) :
    ∃ (j : Fin (n + 1) × Fin (n + 1)) (x : Msg n × Msg n),
      Real.logb 2 n - 4 ≤ (L x : ℝ) + Real.logb 2 (prodClass (bernClass n) (bernClass n) j x) := by
  have hp := bernClass_isPMF n
  have hclass : ∀ t : Fin (n + 1) × Fin (n + 1),
      IsPMF (prodClass (bernClass n) (bernClass n) t) := prodClass_isPMF hp hp
  obtain ⟨j, x, hjx⟩ :=
    code_regret_ge_logb_shtarkov (p := prodClass (bernClass n) (bernClass n)) (L := L) hclass hL
  refine ⟨j, x, le_trans ?_ hjx⟩
  rw [logb_shtarkov_prodClass hp hp]
  have hlog := logb_shtarkov_bernClass_ge n hn
  linarith

end PriceOfUniversality