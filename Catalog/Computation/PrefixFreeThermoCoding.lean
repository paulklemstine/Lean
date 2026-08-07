/-
# Prefix-Free Proof Descriptions: Kraft, Shannon and the Landauer Cost of a Theorem Ensemble

Future Direction 5 of the "Proof Complexity and Thermodynamic Cost" thread asked to replace
the coarse binary scarcity axiom of the finite-ensemble theorems by **Kraft's inequality**,
and to convert counting incompressibility into an *entropy-sensitive* coding theorem with a
sharp equality case.  This file does exactly that, from scratch:

1. `kraft_inequality` — for a finite **prefix-free** set of binary proof descriptions,
   `∑ 2^{-|w|} ≤ 1`.  Proved by the cylinder argument: the length-`L` extensions of distinct
   prefix-free words are disjoint subsets of the `2^L` words of length `L`.
2. `shannon_entropy_lower_bound` — for any length function obeying Kraft, the expected
   description length of a theorem ensemble is at least its Shannon entropy.
3. `expected_length_eq_entropy_iff` — **sharp equality case**: equality holds *iff* the code
   is dyadic-matched, `p i = 2^{-ℓ i}`; and then (`kraftSum_eq_one_of_optimal`) the Kraft
   sum equals `1`, i.e. the prefix code is **complete**.
4. `expected_landauerCost_ge_entropy` — the thermodynamic reading: at temperature `T` the
   expected Landauer cost of erasing the descriptions of a theorem ensemble is at least
   `H(p) · k_B T ln 2`, with equality exactly for complete dyadic codes.

## Main statements

* `card_boolLists`, `card_cylinder` — the combinatorial substrate.
* `kraft_inequality` (real form) and `kraft_inequality_nat` (integer form).
* `kraftSum_le_one_of_prefixFree_code` — Kraft transported from a prefix-free image to an
  index set of theorems.
* `shannon_entropy_lower_bound`, `expected_length_eq_entropy_iff`,
  `kraftSum_eq_one_of_optimal`, `dyadic_code_achieves_entropy`.
* `shannon_fano_lengths`, `optimal_expected_length_bounds` — the matching achievability
  half: the ceiling lengths `⌈−log₂ pᵢ⌉` are Kraft-admissible and overshoot the entropy by
  less than one bit, so the optimal expected description length lies in `[H(p), H(p)+1)`.
* `expected_landauerCost_ge_entropy`, `expected_landauerCost_eq_entropy_iff`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the counting bound "there are only `2^n − 1` descriptions shorter than
  `n`" is the uniform-measure shadow of Kraft's inequality; replacing it by Kraft should turn
  the incompressibility statement into the Shannon source-coding bound, and hence turn the
  linear Landauer cost law into an entropy law.
Experiment (Stage 2): proved Kraft by the cylinder/disjointness argument (no measure theory),
  then Gibbs' inequality from `Real.log_le_sub_one_of_pos`, and the equality case from the
  strict form `Real.add_one_lt_exp`.
Analysis (Stage 3): the equality analysis is where the structure lives.  Writing
  `g i = p i · (q i / p i − 1 − log (q i / p i)) ≥ 0` with `∑ g = KraftSum − 1 ≤ 0` forces
  *both* `q i = p i` for every `i` *and* completeness `KraftSum = 1` simultaneously — the two
  halves of the conjectured characterisation come from one nonnegativity argument.
Critique (Stage 4): positivity `0 < p i` is load-bearing (a zero-probability theorem may be
  given an arbitrarily long codeword without affecting either side, so the equality case
  would fail as stated); we therefore keep it explicit rather than hiding it in a support
  condition.  Kraft alone — not prefix-freeness — is what the coding theorem needs, so the
  two halves of the file are stated independently and joined by
  `kraftSum_le_one_of_prefixFree_code`.
Synthesis (Stage 5): expected thermodynamic cost of a theorem ensemble is bounded below by
  `k_B T ln 2 · H(p)`, and the bound is attained exactly by complete dyadic prefix codes.
-/
import Mathlib
import Novelty.ThermodynamicsOfProof

open Finset Real ThermoProof

namespace PrefixFreeThermo

/-! ## Binary words of a fixed length -/

/-- All binary words of length `n`. -/
def boolLists : ℕ → Finset (List Bool)
  | 0 => {[]}
  | n + 1 => (boolLists n).biUnion (fun l => {false :: l, true :: l})

@[simp] lemma mem_boolLists (n : ℕ) (l : List Bool) : l ∈ boolLists n ↔ l.length = n := by
  induction n generalizing l with
  | zero => cases l <;> simp [boolLists]
  | succ n ih =>
    simp only [boolLists, Finset.mem_biUnion, Finset.mem_insert, Finset.mem_singleton]
    constructor
    · rintro ⟨t, ht, h | h⟩ <;> subst h <;> simp [(ih t).1 ht]
    · intro h
      cases l with
      | nil => simp at h
      | cons b t =>
        refine ⟨t, (ih t).2 (by simpa using h), ?_⟩
        cases b <;> simp

lemma card_boolLists (n : ℕ) : (boolLists n).card = 2 ^ n := by
  induction n with
  | zero => simp [boolLists]
  | succ n ih =>
    rw [boolLists, Finset.card_biUnion]
    · have hc : ∀ l ∈ boolLists n,
          ({false :: l, true :: l} : Finset (List Bool)).card = 2 := by
        intro l _; simp
      rw [Finset.sum_congr rfl hc, Finset.sum_const, ih, smul_eq_mul]
      ring
    · intro x _ y _ hxy
      simp only [Finset.disjoint_left, Finset.mem_insert, Finset.mem_singleton]
      rintro a (rfl | rfl) <;> rintro (h | h) <;> simp_all

/-! ## Cylinders and Kraft's inequality -/

/-- The **cylinder** of a word `w` at depth `L`: all binary words of length `L` extending
`w`.  Distinct prefix-free words have disjoint cylinders. -/
def cylinder (L : ℕ) (w : List Bool) : Finset (List Bool) :=
  (boolLists L).filter (fun u => w <+: u)

lemma cylinder_subset (L : ℕ) (w : List Bool) : cylinder L w ⊆ boolLists L :=
  Finset.filter_subset _ _

lemma card_cylinder {L : ℕ} {w : List Bool} (hw : w.length ≤ L) :
    (cylinder L w).card = 2 ^ (L - w.length) := by
  classical
  have himg : cylinder L w = (boolLists (L - w.length)).image (fun t => w ++ t) := by
    ext u
    simp only [cylinder, Finset.mem_filter, Finset.mem_image, mem_boolLists]
    constructor
    · rintro ⟨hu, t, rfl⟩
      exact ⟨t, by simpa using (by omega : w.length + t.length - w.length = t.length) ▸
        (by simpa using congrArg (· - w.length) hu), rfl⟩
    · rintro ⟨t, ht, rfl⟩
      refine ⟨by simp [ht]; omega, ⟨t, rfl⟩⟩
  rw [himg, Finset.card_image_of_injective _ (fun a b h => List.append_cancel_left h),
    card_boolLists]

/-- A finite set of binary descriptions is **prefix-free** if no description is a proper
prefix of another. -/
def PrefixFree (S : Finset (List Bool)) : Prop :=
  ∀ u ∈ S, ∀ v ∈ S, u <+: v → u = v

lemma cylinder_disjoint {S : Finset (List Bool)} (h : PrefixFree S) (L : ℕ)
    {u v : List Bool} (hu : u ∈ S) (hv : v ∈ S) (huv : u ≠ v) :
    Disjoint (cylinder L u) (cylinder L v) := by
  rw [Finset.disjoint_left]
  intro a ha hb
  simp only [cylinder, Finset.mem_filter] at ha hb
  rcases le_total u.length v.length with hle | hle
  · exact absurd (h u hu v hv (List.prefix_of_prefix_length_le ha.2 hb.2 hle)) huv
  · exact absurd (h v hv u hu (List.prefix_of_prefix_length_le hb.2 ha.2 hle)).symm huv

/-- **Kraft's inequality, integer form.**  If `S` is prefix-free and all its words have
length at most `L`, then `∑_{w ∈ S} 2^{L−|w|} ≤ 2^L`. -/
theorem kraft_inequality_nat {S : Finset (List Bool)} (hpf : PrefixFree S) {L : ℕ}
    (hL : ∀ w ∈ S, w.length ≤ L) :
    ∑ w ∈ S, 2 ^ (L - w.length) ≤ 2 ^ L := by
  classical
  have hcard : ∑ w ∈ S, 2 ^ (L - w.length) = ∑ w ∈ S, (cylinder L w).card :=
    Finset.sum_congr rfl fun w hw => (card_cylinder (hL w hw)).symm
  rw [hcard, ← Finset.card_biUnion (fun u hu v hv huv => cylinder_disjoint hpf L hu hv huv)]
  calc (S.biUnion (cylinder L)).card ≤ (boolLists L).card :=
        Finset.card_le_card (Finset.biUnion_subset.2 fun w _ => cylinder_subset L w)
    _ = 2 ^ L := card_boolLists L

/-- **Kraft's inequality.**  A finite prefix-free set of binary proof descriptions satisfies
`∑_{w ∈ S} 2^{-|w|} ≤ 1`: short descriptions are a scarce resource, quantitatively. -/
theorem kraft_inequality {S : Finset (List Bool)} (hpf : PrefixFree S) :
    ∑ w ∈ S, ((2:ℝ)⁻¹) ^ w.length ≤ 1 := by
  classical
  set L := S.sup List.length with hLdef
  have hL : ∀ w ∈ S, w.length ≤ L := fun w hw => Finset.le_sup (f := List.length) hw
  have hnat := kraft_inequality_nat hpf hL
  have hcast : ((∑ w ∈ S, 2 ^ (L - w.length) : ℕ) : ℝ) ≤ ((2 ^ L : ℕ) : ℝ) := by
    exact_mod_cast hnat
  push_cast at hcast
  have hterm : ∀ w ∈ S, ((2:ℝ)⁻¹) ^ w.length = (2:ℝ) ^ (L - w.length) / 2 ^ L := by
    intro w hw
    have hsplit : (2:ℝ) ^ (L - w.length) * 2 ^ w.length = 2 ^ L := by
      rw [← pow_add, Nat.sub_add_cancel (hL w hw)]
    have h2 : ((2:ℝ) ^ w.length) ≠ 0 := by positivity
    rw [inv_pow, eq_div_iff (by positivity : ((2:ℝ) ^ L) ≠ 0), inv_mul_eq_div,
      div_eq_iff h2]
    exact hsplit.symm
  rw [Finset.sum_congr rfl hterm, ← Finset.sum_div, div_le_one (by positivity)]
  exact hcast

/-! ## Ensembles of theorems, entropy, and the coding bound -/

variable {ι : Type*} [Fintype ι]

/-- The **Kraft sum** of a length function on a finite ensemble of theorems. -/
noncomputable def kraftSum (ℓ : ι → ℕ) : ℝ := ∑ i, ((2:ℝ)⁻¹) ^ (ℓ i)

/-- **Shannon entropy** of a theorem distribution, in bits. -/
noncomputable def entropy (p : ι → ℝ) : ℝ := -∑ i, p i * Real.logb 2 (p i)

/-- Expected description length of the ensemble. -/
noncomputable def expectedLength (p : ι → ℝ) (ℓ : ι → ℕ) : ℝ := ∑ i, p i * (ℓ i : ℝ)

/-- Kraft's inequality transported along an injective prefix-free coding of theorems. -/
theorem kraftSum_le_one_of_prefixFree_code [DecidableEq ι] (c : ι → List Bool)
    (hinj : Function.Injective c) (hpf : PrefixFree (Finset.univ.image c)) :
    kraftSum (fun i => (c i).length) ≤ 1 := by
  classical
  have h := kraft_inequality hpf
  rwa [Finset.sum_image (fun a _ b _ hab => hinj hab)] at h

/-- The pointwise Gibbs estimate: `p · log (q/p) ≤ q − p`. -/
private lemma gibbs_pointwise {a b : ℝ} (ha : 0 < a) (hb : 0 < b) :
    a * (Real.log b - Real.log a) ≤ b - a := by
  have h1 : Real.log (b / a) ≤ b / a - 1 := Real.log_le_sub_one_of_pos (by positivity)
  rw [Real.log_div (ne_of_gt hb) (ne_of_gt ha)] at h1
  have h2 := mul_le_mul_of_nonneg_left h1 (le_of_lt ha)
  have h3 : a * (b / a - 1) = b - a := by field_simp
  linarith [h2, h3.le, h3.ge]

private lemma log_inv_pow (k : ℕ) : Real.log (((2:ℝ)⁻¹) ^ k) = -(k * Real.log 2) := by
  rw [Real.log_pow, Real.log_inv]; ring

/-- The core inequality: `∑ pᵢ (log qᵢ − log pᵢ) ≤ KraftSum − 1`, where `qᵢ = 2^{-ℓᵢ}`. -/
private lemma gibbs_sum (p : ι → ℝ) (hp : ∀ i, 0 < p i) (hsum : ∑ i, p i = 1) (ℓ : ι → ℕ) :
    -(Real.log 2 * expectedLength p ℓ) - ∑ i, p i * Real.log (p i) ≤ kraftSum ℓ - 1 := by
  have hterm : ∀ i ∈ (Finset.univ : Finset ι),
      p i * (Real.log (((2:ℝ)⁻¹) ^ (ℓ i)) - Real.log (p i)) ≤ ((2:ℝ)⁻¹) ^ (ℓ i) - p i := by
    intro i _
    exact gibbs_pointwise (hp i) (by positivity)
  have hsum1 := Finset.sum_le_sum hterm
  have hkey : ∀ i : ι, p i * (Real.log (((2:ℝ)⁻¹) ^ (ℓ i)) - Real.log (p i))
      = -(Real.log 2 * (p i * (ℓ i : ℝ))) - p i * Real.log (p i) := by
    intro i; rw [log_inv_pow]; ring
  have hL : ∑ i, (p i * (Real.log (((2:ℝ)⁻¹) ^ (ℓ i)) - Real.log (p i)))
      = -(Real.log 2 * expectedLength p ℓ) - ∑ i, p i * Real.log (p i) := by
    calc ∑ i, (p i * (Real.log (((2:ℝ)⁻¹) ^ (ℓ i)) - Real.log (p i)))
        = ∑ i, (-(Real.log 2 * (p i * (ℓ i : ℝ))) - p i * Real.log (p i)) :=
          Finset.sum_congr rfl fun i _ => hkey i
      _ = -(Real.log 2 * expectedLength p ℓ) - ∑ i, p i * Real.log (p i) := by
          rw [Finset.sum_sub_distrib]
          congr 1
          rw [expectedLength, Finset.mul_sum, ← Finset.sum_neg_distrib]
  have hR : ∑ i, (((2:ℝ)⁻¹) ^ (ℓ i) - p i) = kraftSum ℓ - 1 := by
    rw [Finset.sum_sub_distrib, hsum]; rfl
  linarith [hL ▸ hsum1, hR ▸ hsum1]

lemma entropy_eq (p : ι → ℝ) :
    entropy p = -(∑ i, p i * Real.log (p i)) / Real.log 2 := by
  unfold entropy
  rw [neg_div, Finset.sum_div]
  congr 1
  exact Finset.sum_congr rfl fun i _ => by rw [Real.logb]; ring

/-- **Shannon's source-coding lower bound for proof descriptions.**  If the description
lengths obey Kraft's inequality — in particular if the descriptions form a prefix-free code
— then the expected description length of a theorem ensemble is at least its Shannon
entropy. -/
theorem shannon_entropy_lower_bound (p : ι → ℝ) (hp : ∀ i, 0 < p i) (hsum : ∑ i, p i = 1)
    (ℓ : ι → ℕ) (hk : kraftSum ℓ ≤ 1) : entropy p ≤ expectedLength p ℓ := by
  have hL2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hg := gibbs_sum p hp hsum ℓ
  rw [entropy_eq, div_le_iff₀ hL2]
  nlinarith [hg, hk]

/-- A dyadic-matched code attains the entropy exactly. -/
theorem dyadic_code_achieves_entropy (p : ι → ℝ) (ℓ : ι → ℕ)
    (hmatch : ∀ i, p i = ((2:ℝ)⁻¹) ^ (ℓ i)) : expectedLength p ℓ = entropy p := by
  have hL2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rw [entropy_eq, eq_div_iff (ne_of_gt hL2)]
  unfold expectedLength
  rw [Finset.sum_mul, ← Finset.sum_neg_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [hmatch i, log_inv_pow]
  ring

/-- Strict Gibbs: `x − 1 = log x` forces `x = 1`. -/
private lemma eq_one_of_log_eq_sub_one {x : ℝ} (hx : 0 < x) (h : x - 1 - Real.log x = 0) :
    x = 1 := by
  by_contra hne
  have hlog : Real.log x ≠ 0 := fun h0 => hne (by
    have := Real.exp_log hx
    rw [h0, Real.exp_zero] at this
    exact this.symm)
  have := Real.add_one_lt_exp hlog
  rw [Real.exp_log hx] at this
  linarith

/-- **Sharp equality case.**  Expected description length equals the Shannon entropy of the
theorem ensemble **iff** the code is dyadic-matched: `pᵢ = 2^{-ℓᵢ}`. -/
theorem expected_length_eq_entropy_iff (p : ι → ℝ) (hp : ∀ i, 0 < p i) (hsum : ∑ i, p i = 1)
    (ℓ : ι → ℕ) (hk : kraftSum ℓ ≤ 1) :
    expectedLength p ℓ = entropy p ↔ ∀ i, p i = ((2:ℝ)⁻¹) ^ (ℓ i) := by
  constructor
  · intro heq
    have hL2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
    -- under equality the relative-entropy term vanishes
    have hzero : ∑ i, p i * (Real.log (((2:ℝ)⁻¹) ^ (ℓ i)) - Real.log (p i)) = 0 := by
      have hE : Real.log 2 * expectedLength p ℓ = -∑ i, p i * Real.log (p i) := by
        rw [heq, entropy_eq]
        field_simp
      have hkey : ∀ i : ι, p i * (Real.log (((2:ℝ)⁻¹) ^ (ℓ i)) - Real.log (p i))
          = -(Real.log 2 * (p i * (ℓ i : ℝ))) - p i * Real.log (p i) := by
        intro i; rw [log_inv_pow]; ring
      calc ∑ i, p i * (Real.log (((2:ℝ)⁻¹) ^ (ℓ i)) - Real.log (p i))
          = ∑ i, (-(Real.log 2 * (p i * (ℓ i : ℝ))) - p i * Real.log (p i)) :=
            Finset.sum_congr rfl fun i _ => hkey i
        _ = -(Real.log 2 * expectedLength p ℓ) - ∑ i, p i * Real.log (p i) := by
            rw [Finset.sum_sub_distrib]
            congr 1
            rw [expectedLength, Finset.mul_sum, ← Finset.sum_neg_distrib]
        _ = 0 := by rw [hE]; ring
    -- each Gibbs defect is nonnegative but they sum to `KraftSum − 1 ≤ 0`
    set q : ι → ℝ := fun i => ((2:ℝ)⁻¹) ^ (ℓ i) with hq
    have hqpos : ∀ i, 0 < q i := fun i => by simp only [hq]; positivity
    set g : ι → ℝ := fun i => p i * (q i / p i - 1 - Real.log (q i / p i)) with hgdef
    have hgnn : ∀ i, 0 ≤ g i := by
      intro i
      have h1 : Real.log (q i / p i) ≤ q i / p i - 1 :=
        Real.log_le_sub_one_of_pos (div_pos (hqpos i) (hp i))
      have : 0 ≤ q i / p i - 1 - Real.log (q i / p i) := by linarith
      exact mul_nonneg (le_of_lt (hp i)) this
    have hgsum : ∑ i, g i = kraftSum ℓ - 1 := by
      have hexp : ∀ i, g i = (q i - p i) - p i * (Real.log (q i) - Real.log (p i)) := by
        intro i
        have hpq : p i * (q i / p i) = q i := by
          rw [mul_comm]; exact div_mul_cancel₀ _ (ne_of_gt (hp i))
        have hsplit : p i * (q i / p i - 1 - Real.log (q i / p i))
            = p i * (q i / p i) - p i - p i * Real.log (q i / p i) := by ring
        simp only [hgdef]
        rw [hsplit, hpq, Real.log_div (ne_of_gt (hqpos i)) (ne_of_gt (hp i))]
      rw [Finset.sum_congr rfl (fun i _ => hexp i), Finset.sum_sub_distrib,
        Finset.sum_sub_distrib, hsum, hzero]
      simp [kraftSum, hq]
    have hle0 : ∑ i, g i ≤ 0 := by rw [hgsum]; linarith
    have hall : ∀ i ∈ (Finset.univ : Finset ι), g i = 0 := by
      have := (Finset.sum_eq_zero_iff_of_nonneg (fun i _ => hgnn i)).1
        (le_antisymm hle0 (Finset.sum_nonneg fun i _ => hgnn i))
      exact this
    intro i
    have hgi : q i / p i - 1 - Real.log (q i / p i) = 0 := by
      have h0 := hall i (Finset.mem_univ i)
      simp only [hgdef] at h0
      rcases mul_eq_zero.1 h0 with h | h
      · exact absurd h (ne_of_gt (hp i))
      · exact h
    have hone := eq_one_of_log_eq_sub_one (x := q i / p i) (div_pos (hqpos i) (hp i)) hgi
    have hqp : q i = p i := by
      have hpne : p i ≠ 0 := ne_of_gt (hp i)
      field_simp at hone
      exact hone
    exact hqp.symm
  · intro hmatch
    exact dyadic_code_achieves_entropy p ℓ hmatch

/-- **Completeness of the optimal code.**  An entropy-attaining code has Kraft sum exactly
`1`: it is a *complete* prefix code, wasting no description space. -/
theorem kraftSum_eq_one_of_optimal (p : ι → ℝ) (hp : ∀ i, 0 < p i) (hsum : ∑ i, p i = 1)
    (ℓ : ι → ℕ) (hk : kraftSum ℓ ≤ 1) (heq : expectedLength p ℓ = entropy p) :
    kraftSum ℓ = 1 := by
  have hmatch := (expected_length_eq_entropy_iff p hp hsum ℓ hk).1 heq
  unfold kraftSum
  rw [← hsum]
  exact (Finset.sum_congr rfl fun i _ => (hmatch i).symm)

/-! ## Achievability: the Shannon–Fano lengths -/

/-- **Achievability (Shannon–Fano).**  The ceiling lengths `ℓ i = ⌈−log₂ p i⌉` obey Kraft's
inequality and overshoot the entropy by less than one bit.  Together with
`shannon_entropy_lower_bound` this pins the optimal expected description length of a theorem
ensemble to the unit interval `[H(p), H(p) + 1)`. -/
theorem shannon_fano_lengths [Nonempty ι] (p : ι → ℝ) (hp : ∀ i, 0 < p i)
    (hsum : ∑ i, p i = 1) :
    ∃ ℓ : ι → ℕ, kraftSum ℓ ≤ 1 ∧ expectedLength p ℓ < entropy p + 1 := by
  have hple : ∀ i, p i ≤ 1 := by
    intro i
    calc p i ≤ ∑ j, p j := Finset.single_le_sum (fun j _ => (hp j).le) (Finset.mem_univ i)
      _ = 1 := hsum
  have hnn : ∀ i, 0 ≤ -Real.logb 2 (p i) := by
    intro i
    have := Real.logb_nonpos (b := 2) (by norm_num) (le_of_lt (hp i)) (hple i)
    linarith
  refine ⟨fun i => ⌈-Real.logb 2 (p i)⌉₊, ?_, ?_⟩
  · -- Kraft: each codeword weight is at most its probability
    have hkey : ∀ i, ((2:ℝ)⁻¹) ^ (⌈-Real.logb 2 (p i)⌉₊) ≤ p i := by
      intro i
      have hceil : -Real.logb 2 (p i) ≤ (⌈-Real.logb 2 (p i)⌉₊ : ℝ) := Nat.le_ceil _
      have h1 : ((2:ℝ)⁻¹) ^ (⌈-Real.logb 2 (p i)⌉₊)
          = (2:ℝ) ^ (-(⌈-Real.logb 2 (p i)⌉₊ : ℝ)) := by
        rw [Real.rpow_neg (by norm_num), Real.rpow_natCast, inv_pow]
      have h2 : (2:ℝ) ^ (-(⌈-Real.logb 2 (p i)⌉₊ : ℝ)) ≤ (2:ℝ) ^ (Real.logb 2 (p i)) :=
        Real.rpow_le_rpow_of_exponent_le (by norm_num) (by linarith)
      rw [Real.rpow_logb (by norm_num) (by norm_num) (hp i)] at h2
      rw [h1]
      exact h2
    calc kraftSum (fun i => ⌈-Real.logb 2 (p i)⌉₊) ≤ ∑ i, p i :=
          Finset.sum_le_sum fun i _ => hkey i
      _ = 1 := hsum
  · -- the ceiling costs less than one extra bit
    have hlt : ∀ i ∈ (Finset.univ : Finset ι),
        p i * ((⌈-Real.logb 2 (p i)⌉₊ : ℝ)) < p i * (-Real.logb 2 (p i) + 1) := by
      intro i _
      exact mul_lt_mul_of_pos_left (Nat.ceil_lt_add_one (hnn i)) (hp i)
    have hstrict : expectedLength p (fun i => ⌈-Real.logb 2 (p i)⌉₊)
        < ∑ i, p i * (-Real.logb 2 (p i) + 1) :=
      Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty hlt
    have hrhs : ∑ i, p i * (-Real.logb 2 (p i) + 1) = entropy p + 1 := by
      have : ∀ i : ι, p i * (-Real.logb 2 (p i) + 1)
          = -(p i * Real.logb 2 (p i)) + p i := fun i => by ring
      rw [Finset.sum_congr rfl (fun i _ => this i), Finset.sum_add_distrib, hsum, entropy,
        ← Finset.sum_neg_distrib]
    linarith [hstrict, hrhs.le, hrhs.ge]

/-- **Two-sided Shannon theorem for proof descriptions.**  The optimal expected description
length of a theorem ensemble lies in `[H(p), H(p) + 1)`. -/
theorem optimal_expected_length_bounds [Nonempty ι] (p : ι → ℝ) (hp : ∀ i, 0 < p i)
    (hsum : ∑ i, p i = 1) :
    ∃ ℓ : ι → ℕ, kraftSum ℓ ≤ 1 ∧ entropy p ≤ expectedLength p ℓ ∧
      expectedLength p ℓ < entropy p + 1 := by
  obtain ⟨ℓ, hk, hlt⟩ := shannon_fano_lengths p hp hsum
  exact ⟨ℓ, hk, shannon_entropy_lower_bound p hp hsum ℓ hk, hlt⟩

/-! ## The thermodynamic reading -/

/-- **Entropy lower bound on expected thermodynamic cost.**  Erasing the description of a
theorem drawn from the ensemble `p` costs, on average, at least `H(p) · k_B T ln 2` — the
Shannon entropy of the theorem distribution is a hard floor on Landauer dissipation, for
every prefix-free (indeed every Kraft-admissible) description scheme. -/
theorem expected_landauerCost_ge_entropy (p : ι → ℝ) (hp : ∀ i, 0 < p i) (hsum : ∑ i, p i = 1)
    (ℓ : ι → ℕ) (hk : kraftSum ℓ ≤ 1) {kB T : ℝ} (hkB : 0 ≤ kB) (hT : 0 ≤ T) :
    landauerCost (entropy p) kB T ≤ landauerCost (expectedLength p ℓ) kB T := by
  unfold landauerCost
  have hlog : (0:ℝ) ≤ Real.log 2 := le_of_lt (Real.log_pos (by norm_num))
  have hfac : (0:ℝ) ≤ kB * T * Real.log 2 := by positivity
  exact mul_le_mul_of_nonneg_right (shannon_entropy_lower_bound p hp hsum ℓ hk) hfac

/-- The thermodynamic bound is attained **exactly** by complete dyadic prefix codes (at
strictly positive temperature). -/
theorem expected_landauerCost_eq_entropy_iff (p : ι → ℝ) (hp : ∀ i, 0 < p i)
    (hsum : ∑ i, p i = 1) (ℓ : ι → ℕ) (hk : kraftSum ℓ ≤ 1) {kB T : ℝ} (hkB : 0 < kB)
    (hT : 0 < T) :
    landauerCost (expectedLength p ℓ) kB T = landauerCost (entropy p) kB T ↔
      ∀ i, p i = ((2:ℝ)⁻¹) ^ (ℓ i) := by
  have hlog : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hfac : (0:ℝ) < kB * T * Real.log 2 := by positivity
  rw [← expected_length_eq_entropy_iff p hp hsum ℓ hk]
  unfold landauerCost
  constructor
  · intro h
    exact mul_right_cancel₀ (ne_of_gt hfac) h
  · intro h; rw [h]

/-! ## A worked example: the complete code `{0, 10, 11}` -/

/-- The classical code `{0, 10, 11}` is prefix-free. -/
example : PrefixFree ({[false], [true, false], [true, true]} : Finset (List Bool)) := by
  unfold PrefixFree
  decide

/-- Its Kraft sum is exactly `1`: the code is *complete*, wasting no description space. -/
example : ∑ w ∈ ({[false], [true, false], [true, true]} : Finset (List Bool)),
    ((2:ℝ)⁻¹) ^ w.length = 1 := by
  norm_num

/-- Matched to the dyadic distribution `p = (1/2, 1/4, 1/4)`, the same code attains the
Shannon entropy exactly — the equality case of `expected_length_eq_entropy_iff`. -/
example : expectedLength (ι := Fin 3) ![1/2, 1/4, 1/4] ![1, 2, 2]
    = entropy ![1/2, 1/4, 1/4] :=
  dyadic_code_achieves_entropy _ _ (by intro i; fin_cases i <;> norm_num)

end PrefixFreeThermo