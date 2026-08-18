/-
# The price of universality, II: minimax redundancy and mutual information

A *universal* code must serve every source in a class `{p θ}` with a single
length function `L`, whereas a *specialised* code may be tuned to one source.
The number of extra bits this costs is the **price of universality**.

Main results of this file, for a finite class `Θ` of sources on a finite
alphabet `A`:

* `kl_compensation` — the exact decomposition
  `∑ θ, π θ * D(p θ ‖ q) = I(π) + D(mixture ‖ q)`, valid for every coding
  distribution `q`. This is the algebraic heart of the redundancy-capacity
  theorem.
* `exists_source_redundancy_ge_mutualInfo` — **lower bound**: whatever code is
  used, some source in the class pays at least the mutual information `I(π)`
  of any prior `π`.
* `price_of_universality_upper` — **upper bound**: the Shannon code built from
  the mixture pays at most `log₂ |Θ| + 1` bits on *every* source of the class.
* `price_of_universality_sandwich` — for a class of `m` sources with pairwise
  disjoint supports the minimax redundancy is exactly `log₂ m`, up to one bit:
  `log₂ m ≤ minimax redundancy ≤ log₂ m + 1`.

The last statement is the promised closed form: the price of universality over
a class of `m` mutually distinguishable sources is `log₂ m` bits, i.e. exactly
the number of bits needed to name the source — no more and no less.
-/
import Novelty.UniversalRedundancyCore

namespace PriceOfUniversality

open Finset Real

variable {A : Type*} [Fintype A] {Θ : Type*} [Fintype Θ]

/-! ## Mixtures and mutual information -/

/-- The Bayes mixture `∑ θ π θ • p θ` of a class of sources under a prior. -/
noncomputable def mixture (pri : Θ → ℝ) (p : Θ → A → ℝ) : A → ℝ :=
  fun a => ∑ θ, pri θ * p θ a

/-- The mutual information between the source index and the message, i.e. the
average divergence of the class members from the mixture. -/
noncomputable def mutualInfo (pri : Θ → ℝ) (p : Θ → A → ℝ) : ℝ :=
  ∑ θ, pri θ * kl (p θ) (mixture pri p)

lemma mixture_nonneg {pri : Θ → ℝ} {p : Θ → A → ℝ} (hpri : ∀ θ, 0 ≤ pri θ)
    (hp : ∀ θ, IsPMF (p θ)) (a : A) : 0 ≤ mixture pri p a :=
  Finset.sum_nonneg fun θ _ => mul_nonneg (hpri θ) ((hp θ).nonneg a)

lemma mixture_isPMF {pri : Θ → ℝ} {p : Θ → A → ℝ} (hpri : IsPMF pri)
    (hp : ∀ θ, IsPMF (p θ)) : IsPMF (mixture pri p) := by
  refine ⟨mixture_nonneg hpri.nonneg hp, ?_⟩
  simp only [mixture]
  rw [Finset.sum_comm]
  have : ∀ θ : Θ, ∑ a, pri θ * p θ a = pri θ := by
    intro θ; rw [← Finset.mul_sum, (hp θ).total, mul_one]
  calc ∑ θ, ∑ a, pri θ * p θ a = ∑ θ, pri θ := Finset.sum_congr rfl fun θ _ => this θ
    _ = 1 := hpri.total

lemma mixture_pos {pri : Θ → ℝ} {p : Θ → A → ℝ} (hpri : ∀ θ, 0 ≤ pri θ)
    (hp : ∀ θ, IsPMF (p θ)) {θ₀ : Θ} {a : A} (h1 : 0 < pri θ₀) (h2 : 0 < p θ₀ a) :
    0 < mixture pri p a := by
  have hterm : 0 < pri θ₀ * p θ₀ a := mul_pos h1 h2
  refine lt_of_lt_of_le hterm ?_
  have hsub : ∑ θ ∈ ({θ₀} : Finset Θ), pri θ * p θ a ≤ ∑ θ, pri θ * p θ a := by
    refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) ?_
    intro θ _ _
    exact mul_nonneg (hpri θ) ((hp θ).nonneg a)
  simpa using hsub

/-! ## The compensation identity -/

/-- **Compensation identity** (a Pythagorean decomposition for relative entropy):
for every coding distribution `q`, the average divergence of the class members
from `q` splits into the mutual information plus the divergence of the mixture
from `q`. -/
theorem kl_compensation {pri : Θ → ℝ} {p : Θ → A → ℝ} {q : A → ℝ}
    (hpri : IsPMF pri) (hpripos : ∀ θ, 0 < pri θ) (hp : ∀ θ, IsPMF (p θ))
    (hq : ∀ a, 0 < q a) :
    ∑ θ, pri θ * kl (p θ) q = mutualInfo pri p + kl (mixture pri p) q := by
  set m := mixture pri p with hm
  have hmpos : ∀ θ : Θ, ∀ a : A, 0 < p θ a → 0 < m a := by
    intro θ a hpa
    exact mixture_pos hpri.nonneg hp (hpripos θ) hpa
  -- pointwise splitting of the log-ratio
  have hsplit : ∀ (θ : Θ) (a : A),
      p θ a * logb 2 (p θ a / q a)
        = p θ a * logb 2 (p θ a / m a) + p θ a * logb 2 (m a / q a) := by
    intro θ a
    rcases eq_or_lt_of_le ((hp θ).nonneg a) with h | h
    · simp [← h]
    · have hma : 0 < m a := hmpos θ a h
      rw [Real.logb_div (ne_of_gt h) (ne_of_gt (hq a)),
        Real.logb_div (ne_of_gt h) (ne_of_gt hma),
        Real.logb_div (ne_of_gt hma) (ne_of_gt (hq a))]
      ring
  have step1 : ∀ θ : Θ, kl (p θ) q
      = kl (p θ) m + ∑ a, p θ a * logb 2 (m a / q a) := by
    intro θ
    rw [kl, kl, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun a _ => hsplit θ a
  have step2 : ∑ θ, pri θ * (∑ a, p θ a * logb 2 (m a / q a)) = kl m q := by
    rw [kl]
    have : ∀ θ : Θ, pri θ * (∑ a, p θ a * logb 2 (m a / q a))
        = ∑ a, (pri θ * p θ a) * logb 2 (m a / q a) := by
      intro θ; rw [Finset.mul_sum]; exact Finset.sum_congr rfl fun a _ => by ring
    rw [Finset.sum_congr rfl fun θ _ => this θ, Finset.sum_comm]
    refine Finset.sum_congr rfl fun a _ => ?_
    rw [← Finset.sum_mul]
    rfl
  calc ∑ θ, pri θ * kl (p θ) q
      = ∑ θ, (pri θ * kl (p θ) m + pri θ * (∑ a, p θ a * logb 2 (m a / q a))) := by
        refine Finset.sum_congr rfl fun θ _ => ?_
        rw [step1 θ]; ring
    _ = (∑ θ, pri θ * kl (p θ) m) + ∑ θ, pri θ * (∑ a, p θ a * logb 2 (m a / q a)) :=
        Finset.sum_add_distrib
    _ = mutualInfo pri p + kl m q := by rw [step2]; rfl

/-! ## The lower bound: universality costs at least the mutual information -/

/-- **Redundancy-capacity lower bound (average form).** For any code, the average
redundancy over the class is at least the mutual information of the prior. -/
theorem average_redundancy_ge_mutualInfo {pri : Θ → ℝ} {p : Θ → A → ℝ} {L : A → ℕ}
    (hpri : IsPMF pri) (hpripos : ∀ θ, 0 < pri θ) (hp : ∀ θ, IsPMF (p θ))
    (hL : IsCode L) :
    mutualInfo pri p ≤ ∑ θ, pri θ * redundancy (p θ) L := by
  set q : A → ℝ := fun a => ((2:ℝ)⁻¹) ^ (L a) with hqdef
  have hqpos : ∀ a, 0 < q a := fun a => by positivity
  have hred : ∀ θ : Θ, redundancy (p θ) L = kl (p θ) q :=
    fun θ => redundancy_eq_kl (hp θ) L
  have hcomp := kl_compensation hpri hpripos hp hqpos
  have hklnn : 0 ≤ kl (mixture pri p) q :=
    kl_nonneg (mixture_isPMF hpri hp) hqpos hL
  have : ∑ θ, pri θ * redundancy (p θ) L = ∑ θ, pri θ * kl (p θ) q :=
    Finset.sum_congr rfl fun θ _ => by rw [hred θ]
  rw [this, hcomp]
  linarith

/-- **Redundancy-capacity lower bound (minimax form).** Whatever universal code is
chosen, *some* source of the class pays at least `I(π)` bits of redundancy, for
every prior `π`. This is the price of universality. -/
theorem exists_source_redundancy_ge_mutualInfo [Nonempty Θ] {pri : Θ → ℝ} {p : Θ → A → ℝ}
    {L : A → ℕ} (hpri : IsPMF pri) (hpripos : ∀ θ, 0 < pri θ) (hp : ∀ θ, IsPMF (p θ))
    (hL : IsCode L) :
    ∃ θ : Θ, mutualInfo pri p ≤ redundancy (p θ) L := by
  obtain ⟨θ₀, -, hmax⟩ :=
    Finset.exists_max_image (univ : Finset Θ) (fun θ => redundancy (p θ) L)
      (univ_nonempty)
  refine ⟨θ₀, le_trans (average_redundancy_ge_mutualInfo hpri hpripos hp hL) ?_⟩
  calc ∑ θ, pri θ * redundancy (p θ) L
      ≤ ∑ _θ : Θ, pri _θ * redundancy (p θ₀) L := by
        refine Finset.sum_le_sum fun θ _ => ?_
        exact mul_le_mul_of_nonneg_left (hmax θ (mem_univ θ)) (hpri.nonneg θ)
    _ = redundancy (p θ₀) L := by rw [← Finset.sum_mul, hpri.total, one_mul]

/-! ## The upper bound: the mixture code -/

/-- The redundancy of the Shannon code built from the mixture is at most the
divergence from the mixture plus one bit. -/
theorem mixture_code_redundancy_le {p : A → ℝ} (hp : IsPMF p) {m : A → ℝ}
    (hmpos : ∀ a, 0 < m a) (hm1 : ∀ a, m a ≤ 1) :
    redundancy p (shannonCode m) ≤ kl p m + 1 := by
  have hlen : ∀ a : A, (shannonCode m a : ℝ) ≤ -logb 2 (m a) + 1 := by
    intro a
    have h : (0:ℝ) ≤ -logb 2 (m a) := by
      have := Real.logb_nonpos (b := 2) (by norm_num) (hmpos a).le (hm1 a)
      linarith
    exact (Nat.ceil_lt_add_one h).le
  have hstep : expLen p (shannonCode m) ≤ ∑ a, p a * (-logb 2 (m a) + 1) :=
    Finset.sum_le_sum fun a _ => mul_le_mul_of_nonneg_left (hlen a) (hp.nonneg a)
  have hexpand : ∑ a, p a * (-logb 2 (m a) + 1) = kl p m + entropy p + 1 := by
    have h1 : ∀ a : A, p a * (-logb 2 (m a) + 1)
        = (p a * logb 2 (p a / m a)) + (-(p a * logb 2 (p a))) + p a := by
      intro a
      rcases eq_or_lt_of_le (hp.nonneg a) with h | h
      · simp [← h]
      · rw [Real.logb_div (ne_of_gt h) (ne_of_gt (hmpos a))]; ring
    calc ∑ a, p a * (-logb 2 (m a) + 1)
        = ∑ a, ((p a * logb 2 (p a / m a)) + (-(p a * logb 2 (p a))) + p a) :=
          Finset.sum_congr rfl fun a _ => h1 a
      _ = (∑ a, p a * logb 2 (p a / m a)) + (∑ a, -(p a * logb 2 (p a)))
            + ∑ a, p a := by
          rw [← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
      _ = kl p m + entropy p + 1 := by rw [hp.total, kl, entropy]
  rw [redundancy]
  linarith

/-- Under the uniform prior, every member of the class is within `log₂ |Θ|` bits
of the mixture. -/
theorem kl_le_logb_card [Nonempty Θ] {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) (θ : Θ) :
    kl (p θ) (mixture (fun _ => (Fintype.card Θ : ℝ)⁻¹) p) ≤ logb 2 (Fintype.card Θ) := by
  set c : ℝ := (Fintype.card Θ : ℝ)⁻¹ with hc
  have hcard : (0:ℝ) < Fintype.card Θ := by
    exact_mod_cast Fintype.card_pos
  have hcpos : 0 < c := by positivity
  set m := mixture (fun _ => c) p with hmdef
  have hlb : ∀ a : A, c * p θ a ≤ m a := by
    intro a
    rw [hmdef, mixture]
    refine Finset.single_le_sum (f := fun θ' => c * p θ' a) ?_ (mem_univ θ)
    intro θ' _
    exact mul_nonneg hcpos.le ((hp θ').nonneg a)
  have hterm : ∀ a : A, p θ a * logb 2 (p θ a / m a) ≤ p θ a * logb 2 (Fintype.card Θ) := by
    intro a
    rcases eq_or_lt_of_le ((hp θ).nonneg a) with h | h
    · simp [← h]
    · have hma : 0 < m a := lt_of_lt_of_le (mul_pos hcpos h) (hlb a)
      have hratio : p θ a / m a ≤ (Fintype.card Θ : ℝ) := by
        rw [div_le_iff₀ hma]
        have h2 := mul_le_mul_of_nonneg_left (hlb a) hcard.le
        rw [hc, ← mul_assoc, mul_inv_cancel₀ (ne_of_gt hcard), one_mul] at h2
        linarith
      have hlog : logb 2 (p θ a / m a) ≤ logb 2 (Fintype.card Θ) :=
        Real.logb_le_logb_of_le (by norm_num) (by positivity) hratio
      exact mul_le_mul_of_nonneg_left hlog h.le
  calc kl (p θ) m = ∑ a, p θ a * logb 2 (p θ a / m a) := rfl
    _ ≤ ∑ a, p θ a * logb 2 (Fintype.card Θ) := Finset.sum_le_sum fun a _ => hterm a
    _ = logb 2 (Fintype.card Θ) := by rw [← Finset.sum_mul, (hp θ).total, one_mul]

/-- **Upper bound on the price of universality.** If every message is possible
under some member of the class, then a single code serves the whole class of
`m = |Θ|` sources at a cost of at most `log₂ m + 1` bits above each source's own
entropy. -/
theorem price_of_universality_upper [Nonempty Θ] {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ))
    (hcov : ∀ a : A, 0 < mixture (fun _ => (Fintype.card Θ : ℝ)⁻¹) p a) :
    ∃ L : A → ℕ, IsCode L ∧ ∀ θ, redundancy (p θ) L ≤ logb 2 (Fintype.card Θ) + 1 := by
  set c : ℝ := (Fintype.card Θ : ℝ)⁻¹ with hc
  set m := mixture (fun _ => c) p with hmdef
  have hcard : (0:ℝ) < Fintype.card Θ := by exact_mod_cast Fintype.card_pos
  have hmpmf : IsPMF m := by
    refine mixture_isPMF ⟨fun _ => by positivity, ?_⟩ hp
    rw [Finset.sum_const, nsmul_eq_mul, hc, Finset.card_univ]
    field_simp
  refine ⟨shannonCode m, shannonCode_isCode hmpmf hcov, fun θ => ?_⟩
  have h1 := mixture_code_redundancy_le (hp θ) hcov hmpmf.le_one
  have h2 := kl_le_logb_card hp θ
  rw [← hmdef] at h2
  linarith

/-! ## Exact price for a class of mutually distinguishable sources -/

/-- A family of sources has *disjoint supports* when no message is possible under
two different members: the sources are perfectly distinguishable from one
observation. -/
def DisjointSupports (p : Θ → A → ℝ) : Prop :=
  ∀ θ θ' : Θ, ∀ a : A, θ ≠ θ' → 0 < p θ a → p θ' a = 0

/-- For perfectly distinguishable sources the mutual information under the uniform
prior is exactly `log₂ m`: the mixture reveals nothing but the identity of the
source, and naming the source costs `log₂ m` bits. -/
theorem mutualInfo_uniform_disjoint [Nonempty Θ] {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ))
    (hdisj : DisjointSupports p) :
    mutualInfo (fun _ => (Fintype.card Θ : ℝ)⁻¹) p = logb 2 (Fintype.card Θ) := by
  set c : ℝ := (Fintype.card Θ : ℝ)⁻¹ with hc
  have hcard : (0:ℝ) < Fintype.card Θ := by exact_mod_cast Fintype.card_pos
  have hcpos : 0 < c := by positivity
  set m := mixture (fun _ => c) p with hmdef
  -- on the support of `p θ`, the mixture is just `c * p θ`
  have hmix : ∀ (θ : Θ) (a : A), 0 < p θ a → m a = c * p θ a := by
    intro θ a hpa
    rw [hmdef, mixture]
    rw [Finset.sum_eq_single θ]
    · intro θ' _ hne
      rw [hdisj θ θ' a (Ne.symm hne) hpa, mul_zero]
    · intro h; exact absurd (mem_univ θ) h
  have hkl : ∀ θ : Θ, kl (p θ) m = logb 2 (Fintype.card Θ) := by
    intro θ
    have hterm : ∀ a : A,
        p θ a * logb 2 (p θ a / m a) = p θ a * logb 2 (Fintype.card Θ) := by
      intro a
      rcases eq_or_lt_of_le ((hp θ).nonneg a) with h | h
      · simp [← h]
      · rw [hmix θ a h]
        have : p θ a / (c * p θ a) = (Fintype.card Θ : ℝ) := by
          rw [hc]; field_simp
        rw [this]
    calc kl (p θ) m = ∑ a, p θ a * logb 2 (p θ a / m a) := rfl
      _ = ∑ a, p θ a * logb 2 (Fintype.card Θ) := Finset.sum_congr rfl fun a _ => hterm a
      _ = logb 2 (Fintype.card Θ) := by rw [← Finset.sum_mul, (hp θ).total, one_mul]
  rw [mutualInfo, ← hmdef]
  calc ∑ _θ : Θ, c * kl (p _θ) m = ∑ _θ : Θ, c * logb 2 (Fintype.card Θ) :=
        Finset.sum_congr rfl fun θ _ => by rw [hkl θ]
    _ = logb 2 (Fintype.card Θ) := by
        rw [Finset.sum_const, nsmul_eq_mul, hc, Finset.card_univ]
        field_simp

/-- **The price of universality, exactly.** For a class of `m` perfectly
distinguishable sources (every message covered), the minimax redundancy is
`log₂ m` up to one bit:

* no code can serve the whole class at a cost below `log₂ m` bits on every
  member, and
* one explicit code (the Shannon code of the uniform mixture) serves the whole
  class at a cost of at most `log₂ m + 1` bits.

Thus universality moves exactly `log₂ m` bits from the shared decompressor into
the message: a decompressor specialised to one member of the class saves
`log₂ m` bits and no more. -/
theorem price_of_universality_sandwich [Nonempty Θ] {p : Θ → A → ℝ}
    (hp : ∀ θ, IsPMF (p θ)) (hdisj : DisjointSupports p)
    (hcov : ∀ a : A, 0 < mixture (fun _ => (Fintype.card Θ : ℝ)⁻¹) p a) :
    (∀ L : A → ℕ, IsCode L → ∃ θ, logb 2 (Fintype.card Θ) ≤ redundancy (p θ) L) ∧
    (∃ L : A → ℕ, IsCode L ∧ ∀ θ, redundancy (p θ) L ≤ logb 2 (Fintype.card Θ) + 1) := by
  constructor
  · intro L hL
    have hcard : (0:ℝ) < Fintype.card Θ := by exact_mod_cast Fintype.card_pos
    have hpri : IsPMF (fun _ : Θ => (Fintype.card Θ : ℝ)⁻¹) := by
      refine ⟨fun _ => by positivity, ?_⟩
      rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ]
      field_simp
    obtain ⟨θ, hθ⟩ :=
      exists_source_redundancy_ge_mutualInfo (pri := fun _ => (Fintype.card Θ : ℝ)⁻¹)
        hpri (fun _ => by positivity) hp hL
    rw [mutualInfo_uniform_disjoint hp hdisj] at hθ
    exact ⟨θ, hθ⟩
  · exact price_of_universality_upper hp hcov

end PriceOfUniversality