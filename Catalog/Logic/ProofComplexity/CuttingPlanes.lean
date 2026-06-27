import Mathlib
import Logic.ProofComplexity.Pigeonhole

/-!
# Proof Complexity III: Cutting Planes and Separation from Resolution

The **cutting planes** proof system reasons about the integer points of a
polytope using two rules: linear combination of inequalities, and the
Chvátal–Gomory rounding rule.  It is strictly stronger than resolution: there are
formulas (notably the pigeonhole principle) with *polynomial-size* cutting-planes
refutations but only *exponential-size* resolution refutations.

This file:

* formalizes integer-linear inequalities and proves soundness of the two
  cutting-planes rules (`add_sound`, `cg_rounding_sound`);
* proves the **counting refutation** of the pigeonhole principle
  (`php_cp_counting`): a single round of additions over the same `{0,1}`
  constraints used in `PHP` produces the contradiction `n + 1 ≤ n`.

The counting refutation is the constructive core of the resolution–cutting-planes
separation: cutting planes refutes `PHP n` with `O(n)` linear reasoning, whereas
resolution provably cannot (Haken).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The two cutting-planes rules each have a one-line
arithmetic soundness proof, and the pigeonhole principle admits a *short* refutation
in this system via the textbook double-counting argument — exhibiting, concretely,
why cutting planes separates from resolution.

Experiment (Experimenter): Modelled an inequality as `∑ c_i x_i ≥ d` over integer
points.  The CG rounding rule (`cg_rounding_sound`) was the delicate one: dividing
a `k`-divisible inequality by `k` and rounding the bound up needs `Int.ceil_le`
plus a rational cast.  The separation surrogate `php_cp_counting` sums the pigeon
inequalities (lower bound `n+1`) and the hole inequalities (upper bound `n`) over
the SAME variables and closes with `Finset.sum_comm` and `omega`.

Analysis (Analyst): `php_cp_counting` is "true and easy" precisely because the
counting argument is *linear*; resolution is forced to be exponential on the same
formula because it cannot express the global count in a single inequality.  This
asymmetry — easy here, exponential there — is the mathematical content of the
separation, recorded faithfully even though Haken's matching lower bound is out of
present reach.

Critique (Critic): The counting refutation uses only the `≥`/`≤` constraints, no
hidden `0 ≤ x ≤ 1` assumption, so it is not vacuous; it is the genuine
double-counting contradiction.  `cg_rounding_sound` is stated for an arbitrary
finite index set and a positive divisor, not a toy special case.

Synthesis (PI): Cutting planes = (linear inequalities, addition, CG rounding),
all sound; and the pigeonhole principle — exponential for resolution — falls in
linearly many cutting-planes steps.  This is the separation, in the direction we
can fully verify.
-/

namespace ProofComplexity

open Finset

/-- **Soundness of the addition rule.** If `x` satisfies `d1 ≤ ∑ c1 x` and
`d2 ≤ ∑ c2 x`, then it satisfies the sum inequality. -/
theorem add_sound {ι : Type*} (s : Finset ι) (c1 c2 : ι → ℤ) (d1 d2 : ℤ)
    (x : ι → ℤ) (h1 : d1 ≤ ∑ i ∈ s, c1 i * x i) (h2 : d2 ≤ ∑ i ∈ s, c2 i * x i) :
    d1 + d2 ≤ ∑ i ∈ s, (c1 i + c2 i) * x i := by
  have : ∑ i ∈ s, (c1 i + c2 i) * x i
      = (∑ i ∈ s, c1 i * x i) + ∑ i ∈ s, c2 i * x i := by
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro i _; ring
  rw [this]; omega

/-- **Soundness of the Chvátal–Gomory rounding rule.** If every coefficient is
divisible by `k > 0` and `d ≤ ∑ c_i x_i`, then dividing through by `k` and rounding
the bound up is still valid at every integer point. -/
theorem cg_rounding_sound {ι : Type*} (s : Finset ι) (c : ι → ℤ) (d k : ℤ)
    (hk : 0 < k) (x : ι → ℤ) (hdiv : ∀ i ∈ s, k ∣ c i)
    (hineq : d ≤ ∑ i ∈ s, c i * x i) :
    ⌈(d : ℚ) / k⌉ ≤ ∑ i ∈ s, (c i / k) * x i := by
  have hsum : ∑ i ∈ s, c i * x i = k * ∑ i ∈ s, (c i / k) * x i := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i hi
    obtain ⟨m, hm⟩ := hdiv i hi
    rw [hm, Int.mul_ediv_cancel_left _ (by omega)]; ring
  rw [hsum] at hineq
  rw [Int.ceil_le, div_le_iff₀ (by exact_mod_cast hk)]
  have : (d : ℚ) ≤ (k : ℚ) * (∑ i ∈ s, (c i / k) * x i : ℤ) := by exact_mod_cast hineq
  push_cast at this ⊢
  linarith [this]

/-- **The cutting-planes counting refutation of the pigeonhole principle.**

Given any integer "assignment" `x` on `(pigeon, hole)` pairs satisfying the
pigeon lower bounds (each pigeon's row sums to at least `1`) and the hole upper
bounds (each hole's column sums to at most `1`), summing all the inequalities
yields `n + 1 ≤ ∑ x ≤ n`, a contradiction.

This is the linear double-counting argument; it shows the pigeonhole principle has
a refutation using only `O(n)` linear-combination steps — in stark contrast with
the exponential resolution lower bound (Haken's theorem). -/
theorem php_cp_counting (n : ℕ) (x : PVar n → ℤ)
    (hpig : ∀ p : Fin (n + 1), 1 ≤ ∑ h : Fin n, x (p, h))
    (hhole : ∀ h : Fin n, (∑ p : Fin (n + 1), x (p, h)) ≤ 1) : False := by
  have hlow : (n + 1 : ℤ) ≤ ∑ p : Fin (n + 1), ∑ h : Fin n, x (p, h) := by
    calc (n + 1 : ℤ) = ∑ _p : Fin (n + 1), (1 : ℤ) := by simp
    _ ≤ ∑ p : Fin (n + 1), ∑ h : Fin n, x (p, h) :=
        Finset.sum_le_sum (fun p _ => hpig p)
  have hhigh : (∑ p : Fin (n + 1), ∑ h : Fin n, x (p, h)) ≤ (n : ℤ) := by
    rw [Finset.sum_comm]
    calc (∑ h : Fin n, ∑ p : Fin (n + 1), x (p, h)) ≤ ∑ _h : Fin n, (1 : ℤ) :=
          Finset.sum_le_sum (fun h _ => hhole h)
    _ = (n : ℤ) := by simp
  omega

end ProofComplexity