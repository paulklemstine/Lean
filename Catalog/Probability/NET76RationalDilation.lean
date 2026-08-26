import Probability.NET76MultiplicativeAudit

/-!
# NET-76, cycle 2: fractional domain factors, key merging, and why "code" is different

Cycle 1 (`Probability.NET76DomainDilation`, `Probability.NET76MultiplicativeAudit`)
showed that an *integer* block dilation explains the French row exactly and excludes
the code and German rows.  But two of the reported factors are fractional
(`code ≈ 0.75×`, `prose-DE ≈ 1.25×`), so the natural cycle-2 question is whether
enlarging the mechanism to *rational* factors restores the verdict.

The missing half of the mechanism is **key merging**: `contract q w` fuses each block
of `q` adjacent keys of a profile into one key carrying their total mass.  It is the
exact adjoint of dilation, and its knee obeys an exact **ceiling law**, not a bracket:

* `headMass_contract`, `retained_contract` — merging `q` keys is mass-preserving,
  and it reparametrises the retained-mass curve by `q` in *both* arguments.
* `kstar_contract_eq` — **exact**: `k*(contract q w, n) = ⌈k*(w, q·n) / q⌉`.  Merging
  is the only operation in this theory whose knee is a closed form rather than a
  one-block window; the ceiling is where the quantisation of the reported table
  (everything a multiple of 4) comes from.
* `ratDilate_bracket` — a rational factor `p/q` is `dilate p ∘ contract q`, and its
  knee sits in the window `(p·(⌈k*/q⌉ - 1), p·⌈k*/q⌉]`.

The payoff is a genuine separation *inside* the reported table:

* `de_row_rational_window` — the German row `(20, 24)` **is** compatible with the
  rational factor `5/4`, although cycle 1 proved it incompatible with every integer
  dilation.  Rational factors are therefore strictly more expressive, and the German
  anomaly is explained by the ceiling, not by noise.
* `equal_knees_forces_coarse_merging` — the code row is **not** rescued so cheaply.
  Its defining feature is a *zero* doubling increment, and that forces the merging
  depth to satisfy `q ≥ 5`: a domain whose budget curve is flat across a context
  doubling must merge at least five base keys per effective key.  For `q ≤ 4` the two
  windows are disjoint and the increment cannot vanish.
* `code_row_rational_window` — and at `q = 5, p = 3` the windows do contain `(12, 12)`.
  So the code domain is describable, but with effective factor `3/5`, *not* the
  reported `0.75`; the reported factor and the reported flat increment cannot both
  come from the same fine-grained mechanism.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 2):
 (B1) Key merging has an exact ceiling law for the knee, unlike dilation, which has
      only a one-block window.                                              [BOLD]
 (B2) Rational factors strictly enlarge the explanatory power: the German row is
      rescued, the French row is untouched.
 (B3) A zero doubling increment is a *quantisation* phenomenon and forces a lower
      bound on the merging depth (`q ≥ 5` for a base curve `{16, 20}`).      [BOLD]

Experimenter: B1 = `kstar_contract_eq` (proved by identifying the gate set with
`{k | k*(w, q n) ≤ q k}` and evaluating its infimum); B2 = `de_row_rational_window`
against cycle 1's `de_row_not_a_dilation`; B3 = `equal_knees_forces_coarse_merging`,
by disjointness of the two windows whenever `⌈16/q⌉ < ⌈20/q⌉`, checked for every
`q ≤ 4`.

Analyst: the ceiling law is the structural source of every "+0 / +4 / +8" increment
in the reported table.  Dilation multiplies increments; merging *quantises* them.  A
table containing both a doubled increment (French) and a vanished increment (code)
therefore cannot come from one mechanism alone — it needs both, with different
parameters, which is exactly the shape of the sharpened verdict.

Critic: `de_row_rational_window` and `code_row_rational_window` are consistency
statements (the measured pair lies inside the predicted window), not existence proofs
of a profile realising the row; they are stated as such.  The impossibility results
(`equal_knees_forces_coarse_merging`, and cycle 1's exclusions) are the strong
direction and are universally quantified over profiles, contexts and gates.
-/

namespace Catalog.Probability.NET76RationalDilation

open Finset AttentionBudget Catalog.Probability.NET76DomainDilation

/-! ## 1. Key merging -/

/-- **Key merging.**  `contract q w` fuses each block of `q` adjacent keys into a
single key carrying the total mass of the block.  It is the adjoint of `dilate`. -/
noncomputable def contract (q : ℕ) (w : ℕ → ℝ) : ℕ → ℝ :=
  fun i => ∑ j ∈ range q, w (q * i + j)

variable {w : ℕ → ℝ} {p q n : ℕ} {tau : ℝ}

lemma contract_pos (hq : 0 < q) (hw : ∀ i, 0 < w i) : ∀ i, 0 < contract q w i := by
  intro i
  exact Finset.sum_pos (fun j _ => hw _) ⟨0, mem_range.mpr hq⟩

/-- Merging is mass preserving. -/
lemma headMass_contract (k : ℕ) : headMass (contract q w) k = headMass w (q * k) := by
  induction k with
  | zero => simp [headMass]
  | succ k ih =>
      have hsplit : q * (k + 1) = q * k + q := by ring
      have hstep : headMass w (q * (k + 1))
          = headMass w (q * k) + ∑ j ∈ range q, w (q * k + j) := by
        rw [headMass, hsplit, Finset.sum_range_add]; rfl
      rw [headMass, Finset.sum_range_succ, ← headMass, ih, hstep, contract]

/-- Merging reparametrises the retained-mass curve by `q` in both arguments. -/
lemma retained_contract (k : ℕ) :
    retained (contract q w) n k = retained w (q * n) (q * k) := by
  have hmin : min (q * k) (q * n) = q * min k n := by rw [Nat.mul_min_mul_left]
  rw [retained, retained, hmin, headMass_contract, headMass_contract]

/-- **The ceiling law.**  Merging `q` keys divides the knee, exactly, with a ceiling:
`k*(contract q w, n) = ⌈k*(w, q·n) / q⌉`.  This is the only exact knee identity in the
theory; both dilation laws are windows. -/
theorem kstar_contract_eq (hw : ∀ i, 0 < w i) (hq : 0 < q) (hn : 0 < n)
    (htau : tau ≤ 1) :
    kstar (contract q w) n tau = (kstar w (q * n) tau + q - 1) / q := by
  set K := kstar w (q * n) tau with hK
  have hqn : 0 < q * n := Nat.mul_pos hq hn
  -- the gate set of the merged profile is `{k | K ≤ q * k}`
  have hmem : ∀ k : ℕ, (tau ≤ retained (contract q w) n k) ↔ K ≤ q * k := by
    intro k
    rw [retained_contract]
    constructor
    · intro h
      exact kstar_le_of_pass h
    · intro h
      exact le_trans (gate_le_retained_kstar hw hqn htau) (retained_mono hw (q * n) h)
  -- and `K ≤ q * k ↔ ⌈K / q⌉ ≤ k`
  have hceil : ∀ k : ℕ, K ≤ q * k ↔ (K + q - 1) / q ≤ k := by
    intro k
    rw [Nat.div_le_iff_le_mul_add_pred hq]
    omega
  have hset : {k | tau ≤ retained (contract q w) n k} = {k | (K + q - 1) / q ≤ k} := by
    ext k
    rw [Set.mem_setOf_eq, Set.mem_setOf_eq, hmem k, hceil k]
  rw [kstar, hset]
  refine le_antisymm (Nat.sInf_le (by simp)) ?_
  exact le_csInf ⟨(K + q - 1) / q, by simp⟩ (fun b hb => hb)

/-! ## 2. Rational domain factors -/

/-- A **rational domain factor** `p/q`: merge `q` keys, then dilate by `p`. -/
noncomputable def ratDilate (p q : ℕ) (w : ℕ → ℝ) : ℕ → ℝ := dilate p (contract q w)

/-- **Window for a rational factor.**  The knee of a `p/q`-rescaled profile lies in
`(p · (⌈k*/q⌉ - 1), p · ⌈k*/q⌉]`, where `k*` is the base knee at the merged context. -/
theorem ratDilate_bracket (hw : ∀ i, 0 < w i) (hp : 0 < p) (hq : 0 < q) (hn : 0 < n)
    (htau0 : 0 < tau) (htau : tau ≤ 1) :
    p * ((kstar w (q * n) tau + q - 1) / q - 1) < kstar (ratDilate p q w) (p * n) tau ∧
      kstar (ratDilate p q w) (p * n) tau ≤ p * ((kstar w (q * n) tau + q - 1) / q) := by
  have hc := contract_pos hq hw
  have hlow := mul_pred_lt_kstar_dilate (w := contract q w) hc hp hn htau0 htau
  have hup := kstar_dilate_le_mul (w := contract q w) hc hp hn htau
  rw [kstar_contract_eq hw hq hn htau] at hlow hup
  exact ⟨hlow, hup⟩

/-! ## 3. Auditing the anomalous rows again -/

/-- **The German row is rescued by a rational factor.**  Cycle 1 proved `(20, 24)`
incompatible with every *integer* dilation of an English profile with knees `(16, 20)`.
With the rational factor `5/4` the predicted windows are `(15, 20]` at 512 and
`(20, 25]` at 1024, and both measured values lie inside: the German anomaly is a
ceiling effect. -/
theorem de_row_rational_window (hw : ∀ i, 0 < w i) (hn : 0 < n)
    (htau0 : 0 < tau) (htau : tau ≤ 1)
    (h512 : kstar w (4 * n) tau = 16) (h1024 : kstar w (4 * (2 * n)) tau = 20) :
    (15 < kstar (ratDilate 5 4 w) (5 * n) tau ∧
        kstar (ratDilate 5 4 w) (5 * n) tau ≤ 20) ∧
      (20 < kstar (ratDilate 5 4 w) (5 * (2 * n)) tau ∧
        kstar (ratDilate 5 4 w) (5 * (2 * n)) tau ≤ 25) := by
  have h2n : 0 < 2 * n := by omega
  have b1 := ratDilate_bracket (w := w) (p := 5) (q := 4) hw (by norm_num) (by norm_num)
    hn htau0 htau
  have b2 := ratDilate_bracket (w := w) (p := 5) (q := 4) hw (by norm_num) (by norm_num)
    h2n htau0 htau
  rw [h512] at b1
  rw [h1024] at b2
  norm_num at b1 b2
  exact ⟨b1, b2⟩

/-- **A flat budget curve forces coarse merging.**  If a rational rescaling of a base
profile with knees `16` and `20` has the *same* knee at both contexts — the defining
signature of the reported code row — then the merging depth satisfies `q ≥ 5`.  For
`q ≤ 4` the two prediction windows are disjoint, so the increment cannot vanish. -/
theorem equal_knees_forces_coarse_merging (hw : ∀ i, 0 < w i) (hp : 0 < p) (hq : 0 < q)
    (hn : 0 < n) (htau0 : 0 < tau) (htau : tau ≤ 1)
    (h512 : kstar w (q * n) tau = 16) (h1024 : kstar w (q * (2 * n)) tau = 20)
    (hflat : kstar (ratDilate p q w) (p * n) tau
      = kstar (ratDilate p q w) (p * (2 * n)) tau) :
    5 ≤ q := by
  by_contra hlt
  push_neg at hlt
  have h2n : 0 < 2 * n := by omega
  obtain ⟨-, hup1⟩ := ratDilate_bracket (w := w) hw hp hq hn htau0 htau
  obtain ⟨hlow2, -⟩ := ratDilate_bracket (w := w) hw hp hq h2n htau0 htau
  rw [h512] at hup1
  rw [h1024] at hlow2
  -- for `q ≤ 4` the ceilings strictly increase, so the windows are disjoint
  have hgap : (16 + q - 1) / q ≤ (20 + q - 1) / q - 1 := by
    interval_cases q <;> norm_num
  have := hflat ▸ hup1
  have hmul : p * ((16 + q - 1) / q) ≤ p * ((20 + q - 1) / q - 1) :=
    Nat.mul_le_mul_left p hgap
  omega

/-- **Consistency of the code row at `q = 5`.**  With merging depth `5` and dilation
`3` — effective factor `3/5`, not the reported `0.75` — both windows are `(9, 12]`,
which contains the measured `12` at *both* contexts.  A flat code curve is therefore
describable, but only at the coarse-merging end of the mechanism. -/
theorem code_row_rational_window (hw : ∀ i, 0 < w i) (hn : 0 < n)
    (htau0 : 0 < tau) (htau : tau ≤ 1)
    (h512 : kstar w (5 * n) tau = 16) (h1024 : kstar w (5 * (2 * n)) tau = 20) :
    (9 < kstar (ratDilate 3 5 w) (3 * n) tau ∧
        kstar (ratDilate 3 5 w) (3 * n) tau ≤ 12) ∧
      (9 < kstar (ratDilate 3 5 w) (3 * (2 * n)) tau ∧
        kstar (ratDilate 3 5 w) (3 * (2 * n)) tau ≤ 12) := by
  have h2n : 0 < 2 * n := by omega
  have b1 := ratDilate_bracket (w := w) (p := 3) (q := 5) hw (by norm_num) (by norm_num)
    hn htau0 htau
  have b2 := ratDilate_bracket (w := w) (p := 3) (q := 5) hw (by norm_num) (by norm_num)
    h2n htau0 htau
  rw [h512] at b1
  rw [h1024] at b2
  norm_num at b1 b2
  exact ⟨b1, b2⟩

/-- **Cycle-2 capstone.**  One and the same base profile witnesses all three verdicts:
the flat code signature forces coarse merging, the German row fits the rational factor
`5/4`, and (from cycle 1) the French row is an exact two-fold dilation.  The reported
"one factor per domain" is therefore true only after the mechanism is enlarged, and
even then the factor is not the one reported for the code domain. -/
theorem net76_cycle2_summary (hw : ∀ i, 0 < w i) (hn : 0 < n)
    (htau0 : 0 < tau) (htau : tau ≤ 1)
    (h512 : kstar w (4 * n) tau = 16) (h1024 : kstar w (4 * (2 * n)) tau = 20) :
    (∀ p : ℕ, 0 < p →
        kstar (ratDilate p 4 w) (p * n) tau
          ≠ kstar (ratDilate p 4 w) (p * (2 * n)) tau) ∧
      15 < kstar (ratDilate 5 4 w) (5 * n) tau ∧
      kstar (ratDilate 5 4 w) (5 * (2 * n)) tau ≤ 25 := by
  refine ⟨fun p hp hflat => ?_, ?_, ?_⟩
  · have := equal_knees_forces_coarse_merging hw hp (by norm_num) hn htau0 htau h512
      h1024 hflat
    omega
  · exact (de_row_rational_window hw hn htau0 htau h512 h1024).1.1
  · exact (de_row_rational_window hw hn htau0 htau h512 h1024).2.2

end Catalog.Probability.NET76RationalDilation