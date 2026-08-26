/-
# U065 — Cycle 2: the mixture excess for *arbitrary* convex functionals, the integer
(CRT) form of the independence law, and a lower bound on the number of carrier primes

Cycle 1 (`U065QRMixture`, `U065NoSingleCarrier`, `U065DickmanHump`,
`U065MechanismSynthesis`) established the exact mixture algebra for the multiplicative
proxy `c ^ (root count)`.  Three questions were left open by that cycle, and this file
closes them.

1. *Is the excess an artefact of the exponential proxy?*  No: `mixture_convex_excess`
   shows the mixture average beats the naive baseline for **every** convex functional of
   the divisibility rate, and `mixture_strictConvex_excess` makes it strict for strictly
   convex ones.  The mechanism is convexity plus mean preservation, nothing else.

2. *Does the product law survive on honest integers?*  Yes:
   `sum_prod_pow_rootCount_zmod` states the factorisation with `N` ranging over
   `ZMod (∏ qᵢ)` and each coordinate obtained by genuine reduction `N mod qᵢ`, via the
   Chinese remainder theorem.

3. *How many primes must be carrying the hump?*  `carrier_count_lower_bound` turns the
   measured amplitude into a lower bound on the number of primes in the mixture:
   `#primes ≥ A / X` with `X = (c−1)²/(2c)`.  Since each single prime contributes at most
   `X`, a hump of amplitude `A` needs at least `A/X` distinct carriers — the quantitative
   form of "the carrier class is divisibility-distributed".

Finally `rhoOne_mixture_ge` upgrades the two-point Dickman hump of cycle 1 to an
arbitrary finite mixture of Dickman arguments.
-/
import Computation.U065NoSingleCarrier
import Computation.U065DickmanHump

namespace U065

open Finset

variable {p : ℕ} [Fact p.Prime]

/-- **Convexity is the whole mechanism.**  For any convex functional `G` of the per-`N`
divisibility rate, the quadratic-residue mixture average is at least the naive baseline
value `p · G 1` obtained by giving every `N` the mean rate. -/
theorem mixture_convex_excess (hp : p ≠ 2) {G : ℝ → ℝ} (hG : ConvexOn ℝ Set.univ G) :
    (p : ℝ) * G 1 ≤ ∑ a : ZMod p, G ((rootCount p a : ℝ)) := by
  have hid := sum_apply_rootCount hp (fun n => G (n : ℝ))
  have hmid : G 1 ≤ (G 0 + G 2) / 2 := by
    have h := hG.2 (Set.mem_univ (0 : ℝ)) (Set.mem_univ (2 : ℝ))
      (by norm_num : (0 : ℝ) ≤ 1 / 2) (by norm_num : (0 : ℝ) ≤ 1 / 2) (by norm_num)
    have harg : ((1 : ℝ) / 2) • (0 : ℝ) + ((1 : ℝ) / 2) • (2 : ℝ) = 1 := by norm_num
    rw [harg] at h
    simp only [smul_eq_mul] at h
    linarith
  have hp3 := three_le_cast hp
  have hcast : ((2 : ℕ) : ℝ) = 2 := by norm_num
  simp only [hcast, Nat.cast_zero, Nat.cast_one] at hid
  rw [hid]
  nlinarith

/-- Strict version: a strictly convex functional gives a strictly larger mixture
average than the naive baseline. -/
theorem mixture_strictConvex_excess (hp : p ≠ 2) {G : ℝ → ℝ}
    (hG : StrictConvexOn ℝ Set.univ G) :
    (p : ℝ) * G 1 < ∑ a : ZMod p, G ((rootCount p a : ℝ)) := by
  have hid := sum_apply_rootCount hp (fun n => G (n : ℝ))
  have hmid : G 1 < (G 0 + G 2) / 2 := by
    have h := hG.2 (Set.mem_univ (0 : ℝ)) (Set.mem_univ (2 : ℝ)) (by norm_num)
      (by norm_num : (0 : ℝ) < 1 / 2) (by norm_num : (0 : ℝ) < 1 / 2) (by norm_num)
    have harg : ((1 : ℝ) / 2) • (0 : ℝ) + ((1 : ℝ) / 2) • (2 : ℝ) = 1 := by norm_num
    rw [harg] at h
    simp only [smul_eq_mul] at h
    linarith
  have hp3 := three_le_cast hp
  have hcast : ((2 : ℕ) : ℝ) = 2 := by norm_num
  simp only [hcast, Nat.cast_zero, Nat.cast_one] at hid
  rw [hid]
  nlinarith

section CRT

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- **Independence law on honest integers.**  Let `q` be pairwise coprime moduli and
`M = ∏ qᵢ`.  Summing the multiplicative smoothness proxy over a complete residue system
`N mod M`, with each coordinate the genuine reduction `N mod qᵢ`, factorises into the
per-prime mixture sums.  This is the Chinese remainder theorem in the form the
divisibility-mixture baseline needs. -/
theorem sum_prod_pow_rootCount_zmod (q : ι → ℕ) [∀ i, Fact (q i).Prime]
    (hcop : Pairwise (Function.onFun Nat.Coprime q)) (c : ι → ℝ)
    [NeZero (∏ i, q i)] :
    ∑ N : ZMod (∏ i, q i),
        ∏ i, (c i) ^ (rootCount (q i)
          (ZMod.castHom (Finset.dvd_prod_of_mem q (Finset.mem_univ i)) (ZMod (q i)) N))
      = ∏ i, ∑ a : ZMod (q i), (c i) ^ (rootCount (q i) a) := by
  classical
  set e := ZMod.prodEquivPi q hcop with he
  have hcomp : ∀ (i : ι) (N : ZMod (∏ i, q i)),
      e N i = ZMod.castHom (Finset.dvd_prod_of_mem q (Finset.mem_univ i)) (ZMod (q i)) N := by
    intro i N
    have hhom : ((Pi.evalRingHom (fun i => ZMod (q i)) i).comp
        (e : ZMod (∏ i, q i) →+* ((i : ι) → ZMod (q i))))
        = ZMod.castHom (Finset.dvd_prod_of_mem q (Finset.mem_univ i)) (ZMod (q i)) :=
      RingHom.ext_zmod _ _
    exact congrArg (fun f : ZMod (∏ i, q i) →+* ZMod (q i) => f N) hhom
  have hreindex : ∑ N : ZMod (∏ i, q i), ∏ i, (c i) ^ (rootCount (q i) (e N i))
      = ∑ x : (i : ι) → ZMod (q i), ∏ i, (c i) ^ (rootCount (q i) (x i)) :=
    Equiv.sum_comp e.toEquiv (fun x => ∏ i, (c i) ^ (rootCount (q i) (x i)))
  calc ∑ N : ZMod (∏ i, q i), ∏ i, (c i) ^ (rootCount (q i)
          (ZMod.castHom (Finset.dvd_prod_of_mem q (Finset.mem_univ i)) (ZMod (q i)) N))
      = ∑ N : ZMod (∏ i, q i), ∏ i, (c i) ^ (rootCount (q i) (e N i)) := by
        refine Finset.sum_congr rfl (fun N _ => Finset.prod_congr rfl (fun i _ => ?_))
        rw [hcomp i N]
    _ = ∑ x : (i : ι) → ZMod (q i), ∏ i, (c i) ^ (rootCount (q i) (x i)) := hreindex
    _ = ∑ x ∈ Fintype.piFinset (fun i => (Finset.univ : Finset (ZMod (q i)))),
          ∏ i, (c i) ^ (rootCount (q i) (x i)) := by rw [Fintype.piFinset_univ]
    _ = ∏ i, ∑ a : ZMod (q i), (c i) ^ (rootCount (q i) a) := sum_prod_pow_rootCount q c

end CRT

section Bounds

variable {q : ℕ} [Fact q.Prime]

/-- Each prime contributes at most the shape value `X = (c−1)²/(2c)` to the amplitude. -/
theorem logExcess_le_shape (hq : q ≠ 2) {c : ℝ} (hc : 0 < c) :
    logExcess q c ≤ (c - 1) ^ 2 / (2 * c) := by
  have hX : 0 ≤ (c - 1) ^ 2 / (2 * c) := by positivity
  have h1 := logExcess_le hq hc
  have h2 : Real.log (1 + (c - 1) ^ 2 / (2 * c)) ≤ (c - 1) ^ 2 / (2 * c) := by
    have := Real.log_le_sub_one_of_pos (x := 1 + (c - 1) ^ 2 / (2 * c)) (by linarith)
    linarith
  linarith

variable {ι : Type*} [Fintype ι]

/-- The total hump amplitude is at most `k · X`, with `k` the number of primes. -/
theorem humpLogAmplitude_le (Q : ι → ℕ) [∀ i, Fact (Q i).Prime] (hQ : ∀ i, Q i ≠ 2)
    {c : ℝ} (hc : 0 < c) :
    humpLogAmplitude Q c ≤ (Fintype.card ι : ℝ) * ((c - 1) ^ 2 / (2 * c)) := by
  have hle := Finset.sum_le_sum
    (fun i (_ : i ∈ (Finset.univ : Finset ι)) => logExcess_le_shape (hQ i) hc)
  simpa [humpLogAmplitude, Finset.sum_const, Finset.card_univ, nsmul_eq_mul] using hle

/-- **Lower bound on the number of carrier primes.**  A hump of amplitude `A` produced
by a divisibility mixture with weight `c` needs at least `A / X` distinct primes, where
`X = (c−1)²/(2c)` is the most any single prime can contribute.  Together with
`no_single_carrier` this is the formal shape of the experimental conclusion: the feature
is carried by the small-prime divisibility distribution, not by any one covariate. -/
theorem carrier_count_lower_bound (Q : ι → ℕ) [∀ i, Fact (Q i).Prime] (hQ : ∀ i, Q i ≠ 2)
    {c : ℝ} (hc : 0 < c) (hc1 : c ≠ 1) :
    humpLogAmplitude Q c / ((c - 1) ^ 2 / (2 * c)) ≤ (Fintype.card ι : ℝ) := by
  have hXpos : 0 < (c - 1) ^ 2 / (2 * c) := by
    have : 0 < (c - 1) ^ 2 := pow_two_pos_of_ne_zero (sub_ne_zero.mpr hc1)
    positivity
  rw [div_le_iff₀ hXpos]
  simpa [mul_comm] using humpLogAmplitude_le Q hQ hc

end Bounds

section GeneralMixture

/-- **General mixture Jensen bound for the Dickman branch.**  For an arbitrary finite
mixture of Dickman arguments the mixture-averaged rate is at least the rate at the mean
argument: the two-point hump of cycle 1 is the simplest instance of a completely
general phenomenon. -/
theorem rhoOne_mixture_ge {ι : Type*} (t : Finset ι) (w z : ι → ℝ)
    (hw : ∀ i ∈ t, 0 ≤ w i) (hw1 : ∑ i ∈ t, w i = 1) (hz : ∀ i ∈ t, 0 < z i) :
    rhoOne (∑ i ∈ t, w i * z i) ≤ ∑ i ∈ t, w i * rhoOne (z i) := by
  have h := rhoOne_convexOn.map_sum_le (t := t) (w := w) (p := z) hw hw1
    (fun i hi => Set.mem_Ioi.mpr (hz i hi))
  simpa [smul_eq_mul] using h

end GeneralMixture

end U065