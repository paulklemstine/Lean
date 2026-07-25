import Mathlib
import Logic.JarzynskiLandauer
import Physics.LandauerSecondLaw
import Physics.LandauerRelativeEntropy

/-!
# Maximum-Entropy Landauer Cost: the Uniform Memory is the Worst Case to Erase

**Catalog category (v19a menu): cross-domain bridge.**
This file bridges *information theory* (Shannon entropy, the maximum-entropy principle)
with the *thermodynamic* Landauer cost, reusing the **Gibbs inequality**
`LandauerRelativeEntropy.relativeEntropy_nonneg` and the **second law**
`LandauerSecondLaw.jarzynski_second_law` already in the catalog.

`Physics.LandauerThermodynamicLimit` analysed erasure of the *uniform* `n`-bit
register (cost `n·kT·log 2`). Here we treat an **arbitrary** initial distribution `p`
on a finite memory with `N` states and prove two things:

* the generalised Landauer bound: erasing a memory in state `p` costs at least
  `kT·H(p)` (`landauer_general_erasure_bound`); and
* the **maximum-entropy bound** `H(p) ≤ log N` with the clean identity
  `H(p) = log N − D(p‖uniform)` (`shannonEntropy_eq_log_card_sub_relEntropy`,
  `shannonEntropy_le_log_card`), obtained from the catalog's Gibbs inequality.

Combining them: the uniform memory has the largest entropy and is therefore the
**most expensive** `N`-state memory to erase (`landauer_cost_le_uniform`), so the
uniform/`n`-bit Landauer costs studied previously are the worst case.

## Main results

* `unif` / `unif_isPMF` / `unif_pos` — the uniform PMF on a nonempty finite memory.
* `shannonEntropy_eq_log_card_sub_relEntropy` — `H(p) = log N − D(p‖uniform)`.
* `shannonEntropy_le_log_card` — **maximum-entropy bound** `H(p) ≤ log N`.
* `shannonEntropy_uniform_eq_log_card` — the uniform memory attains the maximum.
* `landauer_general_erasure_bound` — `kT·H(p) ≤ E[W]` for arbitrary erasure.
* `landauer_cost_le_uniform` — uniform is the worst case: `kT·H(p) ≤ kT·log N`.

## References
- Jaynes, E.T. (1957). Information theory and statistical mechanics.
- Landauer, R. (1961). Irreversibility and heat generation in the computing process.
- Cover, T.M. & Thomas, J.A. (2006). Elements of Information Theory (max-entropy bound).
-/

noncomputable section

open BigOperators Real Finset
open JarzynskiLandauer

namespace LandauerMaxEntropy

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): The catalog only erased the *uniform* register. We conjectured
--   (i) a Landauer bound kT·H(p) for ARBITRARY initial p, and (ii) that the uniform memory
--   maximises H and is therefore the most expensive N-state memory to erase. The bold unifying
--   claim: every previous uniform/n-bit Landauer cost is the WORST case of a single inequality.
-- Experiment (Experimenter): The bridge is the Gibbs identity H(p) = log N - D(p‖uniform).
--   Expanding D(p‖uniform) with uniform = 1/N: ∑ p·log(p/(1/N)) = ∑ p·log p + log N·∑p
--   = -H(p) + log N (the p=0 terms vanish by the negMulLog / p-factor convention). Then
--   nonnegativity of D — already proved in the catalog as relativeEntropy_nonneg (Gibbs) — gives
--   H(p) ≤ log N immediately. The Landauer bound is jarzynski_second_law with ΔF = kT·H(p).
-- Analysis (Analyst): Max-entropy is Gibbs in disguise; reusing the catalog's Gibbs lemma keeps
--   this a genuine EXTENSION (not a re-proof). The "uniform is worst case" corollary then needs
--   only kT > 0 and monotonicity of multiplication.
-- Critique (Critic): Need Nonempty Ω so 1/N is a genuine positive PMF (else card 0, division by
--   zero). The entropy identity must handle p ω = 0 outcomes; the p-factor makes 0·log(...) = 0
--   so no special casing of the support is needed. The cost-comparison uses 0 ≤ kT, an honest
--   hypothesis. None of the main results is simp/decide-only.
-- Synthesis (PI): A maximum-entropy layer: arbitrary-distribution Landauer bound + the fact
--   that uniform memories are the costliest, unifying the prior uniform-register results.
-- !-- end Lab Notes -- !--

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-- The uniform probability mass function on a finite memory with `N = card Ω` states. -/
def unif (Ω : Type*) [Fintype Ω] : Ω → ℝ := fun _ => 1 / (Fintype.card Ω)

/-
The uniform distribution is a probability mass function.
-/
theorem unif_isPMF : IsPMF (unif Ω) := by
  constructor <;> norm_num [ unif ]

/-
The uniform distribution is strictly positive (full support).
-/
theorem unif_pos (ω : Ω) : 0 < unif Ω ω := by
  exact one_div_pos.mpr ( Nat.cast_pos.mpr Fintype.card_pos )

/-
**Entropy–relative-entropy identity.** The Shannon entropy of any PMF `p` equals
`log N` minus the relative entropy of `p` against the uniform reference, where
`N = card Ω`. This is the bridge that turns Gibbs' inequality into the
maximum-entropy bound.
-/
theorem shannonEntropy_eq_log_card_sub_relEntropy (p : Ω → ℝ) (hp : IsPMF p) :
    shannonEntropy p
      = Real.log (Fintype.card Ω) - LandauerRelativeEntropy.relativeEntropy p (unif Ω) := by
  unfold shannonEntropy;
  have hN : (0 : ℝ) < Fintype.card Ω := Nat.cast_pos.mpr Fintype.card_pos
  have h_log_mul : ∀ ω, p ω * Real.log (p ω / (1 / Fintype.card Ω)) = p ω * Real.log (p ω) + p ω * Real.log (Fintype.card Ω) := by
    intro ω
    by_cases h : p ω = 0
    · simp [h]
    · rw [Real.log_div h (by positivity), Real.log_div one_ne_zero (ne_of_gt hN), Real.log_one]
      ring
  unfold LandauerRelativeEntropy.relativeEntropy; simp_all +decide ;
  unfold unif; simp_all +decide [ div_eq_mul_inv, Real.negMulLog ] ;
  simp +decide [ Finset.sum_add_distrib, ← Finset.sum_mul _ _ _, hp.2 ]

/-
**Maximum-entropy bound.** Any PMF on an `N`-state memory has Shannon entropy at
most `log N`. Proved from the catalog's Gibbs inequality
(`LandauerRelativeEntropy.relativeEntropy_nonneg`).
-/
theorem shannonEntropy_le_log_card (p : Ω → ℝ) (hp : IsPMF p) :
    shannonEntropy p ≤ Real.log (Fintype.card Ω) := by
  rw [ shannonEntropy_eq_log_card_sub_relEntropy ];
  · exact sub_le_self _ ( LandauerRelativeEntropy.relativeEntropy_nonneg p ( unif Ω ) hp ( unif_isPMF ) ( unif_pos ) );
  · exact hp

/-
The uniform memory attains the maximum entropy `log N`.
-/
theorem shannonEntropy_uniform_eq_log_card :
    shannonEntropy (unif Ω) = Real.log (Fintype.card Ω) := by
  convert shannonEntropy_eq_log_card_sub_relEntropy ( unif Ω ) ( unif_isPMF ) using 1;
  simp +decide [ LandauerRelativeEntropy.relativeEntropy ]

omit [Nonempty Ω] in
/-- **Generalised Landauer bound.** For an *arbitrary* initial distribution `p` on a
finite memory, erasing it (modelled by the Jarzynski equality at inverse temperature
`α = (kT)⁻¹` with free-energy cost `ΔF = kT·H(p)`) dissipates a mean work of at least
`kT·H(p)`. -/
theorem landauer_general_erasure_bound (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ)
    (k T : ℝ) (hk : 0 < k) (hT : 0 < T)
    (hJ : JarzynskiCondition p W (k * T)⁻¹ (k * T * shannonEntropy p)) :
    k * T * shannonEntropy p ≤ expect p W :=
  LandauerSecondLaw.jarzynski_second_law p hp W (k * T)⁻¹ (k * T * shannonEntropy p)
    (inv_pos.2 (mul_pos hk hT)) hJ

/-
**Uniform memory is the worst case.** For `k, T ≥ 0`, the Landauer free-energy cost
`kT·H(p)` of erasing any `N`-state memory is at most `kT·log N`, the cost of erasing the
maximum-entropy (uniform) memory.
-/
theorem landauer_cost_le_uniform (p : Ω → ℝ) (hp : IsPMF p) (k T : ℝ)
    (hk : 0 ≤ k) (hT : 0 ≤ T) :
    k * T * shannonEntropy p ≤ k * T * Real.log (Fintype.card Ω) := by
  exact mul_le_mul_of_nonneg_left ( shannonEntropy_le_log_card p hp ) ( mul_nonneg hk hT )

end LandauerMaxEntropy

end