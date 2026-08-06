/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license.

# No universal maximum without resource normalisation

A *theory language* here is any class of developments equipped with

* a theorem count and a source length,
* a semantics (the set of statements the development actually settles), and
* a conservative inflation operator `extend T n` which states `n` further
  consequences **without changing the semantics**, at *sublinear* marginal source
  cost.

The main theorem `no_global_maximum` shows that raw theorem-per-line fitness is
unbounded on such a language, so no development is a global champion — even
though every witness produced is semantically identical to the one it came from
(`extend_semantics_constant`).  Together with the finite maximum principle this
gives the sharp dichotomy `normalization_dichotomy`: a global champion is a
meaningful notion only relative to a bounded, normalised comparison class.

A concrete language with marginal cost `Nat.sqrt` is provided
(`sqrtLanguage`), so the hypotheses are not vacuous.
-/

import Catalog.Pythagorean.TheoryFitness.Core

namespace TheoryFitness

/-- A theory language admitting conservative inflation at sublinear marginal
source cost. -/
structure Language where
  /-- the developments expressible in the language -/
  Th : Type
  /-- number of corpus statements a development states and proves -/
  count : Th → ℕ
  /-- source length of a development -/
  len : Th → ℕ
  /-- the semantic content of a development -/
  semantics : Th → Set ℕ
  /-- marginal source cost of stating `n` further consequences -/
  marginal : ℕ → ℕ
  /-- conservative inflation: state `n` more consequences of what is proved -/
  extend : Th → ℕ → Th
  count_extend : ∀ T n, count (extend T n) = count T + n
  len_extend : ∀ T n, len (extend T n) = len T + marginal n
  /-- inflation is conservative: it adds no semantic content -/
  sem_extend : ∀ T n, semantics (extend T n) = semantics T
  /-- the marginal cost is sublinear -/
  marginal_sublinear : ∀ c : ℚ, 0 < c → ∃ N, ∀ n, N ≤ n → (marginal n : ℚ) ≤ c * n

/-- Raw, unnormalised fitness: theorems per line. -/
def rawFitness (L : Language) (T : L.Th) : ℚ := (L.count T : ℚ) / (L.len T : ℚ)

variable {L : Language}

/-- Conservativity: inflation never changes what a development means. -/
theorem extend_semantics_constant (T : L.Th) (n : ℕ) :
    L.semantics (L.extend T n) = L.semantics T := L.sem_extend T n

/-- Key quantitative step: for a positive target `M`, sublinearity of the
marginal cost produces an inflation whose raw fitness exceeds `M`. -/
theorem exists_extend_fitness_gt_of_pos (T : L.Th) (h0 : 0 < L.len T)
    {M : ℚ} (hM : 0 < M) : ∃ n : ℕ, M < rawFitness L (L.extend T n) := by
  obtain ⟨N, hN⟩ := L.marginal_sublinear (1 / (2 * M)) (by positivity)
  obtain ⟨k, hk⟩ := exists_nat_gt (2 * M * (L.len T : ℚ))
  refine ⟨max N k + 1, ?_⟩
  set n : ℕ := max N k + 1 with hn
  have hnN : N ≤ n := le_trans (le_max_left N k) (Nat.le_succ _)
  have hnk : (k : ℚ) ≤ (n : ℚ) := by
    have : k ≤ n := le_trans (le_max_right N k) (Nat.le_succ _)
    exact_mod_cast this
  have hmarg : (L.marginal n : ℚ) ≤ (1 / (2 * M)) * n := hN n hnN
  have hLQ : (0 : ℚ) < (L.len T : ℚ) := by exact_mod_cast h0
  have hnQ : (0 : ℚ) < (n : ℚ) := by positivity
  have hbig : 2 * M * (L.len T : ℚ) < (n : ℚ) := lt_of_lt_of_le hk hnk
  -- the denominator of the inflated fitness
  have hden : (0 : ℚ) < (L.len (L.extend T n) : ℚ) := by
    have : L.len T ≤ L.len (L.extend T n) := by rw [L.len_extend]; omega
    have h' : 0 < L.len (L.extend T n) := lt_of_lt_of_le h0 this
    exact_mod_cast h'
  rw [rawFitness, lt_div_iff₀ hden]
  have hlen : (L.len (L.extend T n) : ℚ) = (L.len T : ℚ) + (L.marginal n : ℚ) := by
    rw [L.len_extend]; push_cast; ring
  have hcount : (L.count (L.extend T n) : ℚ) = (L.count T : ℚ) + (n : ℚ) := by
    rw [L.count_extend]; push_cast; ring
  rw [hlen, hcount]
  have hhalf : M * ((1 / (2 * M)) * n) = n / 2 := by field_simp
  have hstep : M * (L.marginal n : ℚ) ≤ (n : ℚ) / 2 := by
    calc M * (L.marginal n : ℚ) ≤ M * ((1 / (2 * M)) * n) :=
          mul_le_mul_of_nonneg_left hmarg (le_of_lt hM)
      _ = (n : ℚ) / 2 := hhalf
  have hcnt : (0 : ℚ) ≤ (L.count T : ℚ) := by positivity
  nlinarith [hstep, hbig, hcnt]

/-- Raw fitness is unbounded above on any language with conservative sublinear
inflation. -/
theorem rawFitness_unbounded (T : L.Th) (h0 : 0 < L.len T) (M : ℚ) :
    ∃ n : ℕ, M < rawFitness L (L.extend T n) := by
  rcases lt_or_ge 0 M with hM | hM
  · exact exists_extend_fitness_gt_of_pos T h0 hM
  · obtain ⟨n, hn⟩ := exists_extend_fitness_gt_of_pos T h0 (show (0:ℚ) < 1 by norm_num)
    exact ⟨n, lt_of_le_of_lt hM (by linarith)⟩

/-- **No universal maximum without resource normalisation.**  In a language
permitting conservative addition of independently stated consequences at
sublinear marginal source cost, raw theorem-per-line fitness has no global
maximum. -/
theorem no_global_maximum (T0 : L.Th) (h0 : 0 < L.len T0) :
    ¬ ∃ T : L.Th, ∀ U : L.Th, rawFitness L U ≤ rawFitness L T := by
  rintro ⟨T, hT⟩
  obtain ⟨n, hn⟩ := rawFitness_unbounded T0 h0 (rawFitness L T)
  exact absurd (hT (L.extend T0 n)) (not_le.2 hn)

/-- Moreover the unbounded family is semantically inert: every witness has the
same semantics as the base development, so the divergence of raw fitness records
no mathematical progress at all. -/
theorem unbounded_witnesses_are_semantically_inert (T0 : L.Th) (h0 : 0 < L.len T0)
    (M : ℚ) :
    ∃ n : ℕ, M < rawFitness L (L.extend T0 n) ∧
      L.semantics (L.extend T0 n) = L.semantics T0 :=
  let ⟨n, hn⟩ := rawFitness_unbounded T0 h0 M
  ⟨n, hn, L.sem_extend T0 n⟩

/-- **Sharp dichotomy.**  Fitness maxima exist on every finite (normalised)
comparison class, and never on the full expressible class.  Normalisation is
therefore exactly the decisive hypothesis. -/
theorem normalization_dichotomy (T0 : L.Th) (h0 : 0 < L.len T0)
    (F : Finset L.Th) (hF : F.Nonempty) :
    (∃ b ∈ F, ∀ a ∈ F, rawFitness L a ≤ rawFitness L b) ∧
      ¬ ∃ T : L.Th, ∀ U : L.Th, rawFitness L U ≤ rawFitness L T :=
  ⟨F.exists_max_image (fun a => rawFitness L a) hF, no_global_maximum T0 h0⟩

/-! ## A concrete language: marginal cost `Nat.sqrt` -/

/-- `Nat.sqrt` is sublinear: for every positive rate `c` it eventually stays
below `c * n`. -/
theorem sqrt_sublinear (c : ℚ) (hc : 0 < c) :
    ∃ N, ∀ n, N ≤ n → (Nat.sqrt n : ℚ) ≤ c * n := by
  obtain ⟨k, hk⟩ := exists_nat_gt (1 / c)
  refine ⟨k * k + 1, fun n hn => ?_⟩
  have hkn : k ≤ Nat.sqrt n := by
    rw [Nat.le_sqrt]
    omega
  have hkQ : (k : ℚ) ≤ (Nat.sqrt n : ℚ) := by exact_mod_cast hkn
  have hsq : (Nat.sqrt n) ^ 2 ≤ n := Nat.sqrt_le' n
  have hsqQ : (Nat.sqrt n : ℚ) * (Nat.sqrt n : ℚ) ≤ (n : ℚ) := by
    have : ((Nat.sqrt n ^ 2 : ℕ) : ℚ) ≤ (n : ℚ) := by exact_mod_cast hsq
    push_cast at this
    nlinarith [this]
  have hck : 1 < c * k := by
    rw [div_lt_iff₀ hc] at hk
    linarith
  have hnn : (0 : ℚ) ≤ (Nat.sqrt n : ℚ) := by positivity
  have h2 : (1 : ℚ) < c * (Nat.sqrt n : ℚ) := by nlinarith [hkQ, hck, hc]
  calc (Nat.sqrt n : ℚ) = 1 * (Nat.sqrt n : ℚ) := by ring
    _ ≤ (c * (Nat.sqrt n : ℚ)) * (Nat.sqrt n : ℚ) := by nlinarith [h2, hnn]
    _ = c * ((Nat.sqrt n : ℚ) * (Nat.sqrt n : ℚ)) := by ring
    _ ≤ c * (n : ℚ) := by nlinarith [hsqQ, hc]

/-- A concrete theory language: a development is a pair (theorem count, source
length); inflation by `n` consequences costs `Nat.sqrt n` extra lines and does
not change the semantics. -/
def sqrtLanguage : Language where
  Th := ℕ × ℕ
  count := Prod.fst
  len := Prod.snd
  semantics := fun _ => Set.univ
  marginal := Nat.sqrt
  extend := fun T n => (T.1 + n, T.2 + Nat.sqrt n)
  count_extend := fun _ _ => rfl
  len_extend := fun _ _ => rfl
  sem_extend := fun _ _ => rfl
  marginal_sublinear := sqrt_sublinear

/-- The hypotheses of `no_global_maximum` are satisfiable: the concrete
`sqrtLanguage` has no fitness champion. -/
theorem sqrtLanguage_no_global_maximum :
    ¬ ∃ T : sqrtLanguage.Th, ∀ U : sqrtLanguage.Th,
        rawFitness sqrtLanguage U ≤ rawFitness sqrtLanguage T :=
  no_global_maximum (L := sqrtLanguage) (1, 1) Nat.one_pos

end TheoryFitness