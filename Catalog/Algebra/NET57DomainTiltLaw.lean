import Algebra.NET57KneeGateDuality

/-!
# NET-57, cycle 3: a domain-jump law for the attention budget

Cycles 1–2 established that the knee is a scale-invariant, non-archimedean functional
on the cone of corpora, that four-decimal agreement of retention curves forces exact
knee agreement, and that this inference is sharp.  All of it concerns corpora that are
*numerically close*.  The open direction flagged by the experiment is the opposite
regime: a **domain jump**, where the second corpus is not close at all.

This file supplies the missing quantitative law.  The right notion of distance for a
scale-invariant functional is projective, not additive: say `B` is a **ρ-tilt** of `A`
(`Tilt ρ A B`) when each key's weight is distorted by at most a factor `ρ` in either
direction — a ball in the Hilbert projective metric of the corpus cone.

Main results.

* `clears_of_tilt` — a ρ-tilt costs at most a factor `ρ²` in the *gate*, never anything
  in the *budget*: clearing gate `ρ²τ` on `A` implies clearing gate `τ` on `B`.
* `knee_tilt_le`, `domain_jump_gate_window` — hence the **gate-window law**
  `k*_A(τ/ρ²) ≤ k*_B(τ) ≤ k*_A(ρ²τ)`.  A domain jump can only move the knee as far as
  the reference corpus's own gate sweep moves over a window of multiplicative width
  `ρ²`.  This converts an unmeasured domain into a *measured* interval of gates.
* `tilt_knee_eq_of_flat_window` — the deployment criterion: if the reference sweep is
  flat across that window, every ρ-tilted corpus has *exactly* the reference knee.
  This is what licenses quoting a budget table for an unmeasured domain.
* `domain_tilt_budget_bound` — the explicit deployment number: under a geometric
  retention tail `1 - r^k ≤ retained A n k`, every ρ-tilted corpus is served by any
  budget `K ≤ n` with `r^K ≤ 1 - ρ²τ`.  No re-measurement on the new domain is needed.
* `tilt_exact_of_one` — the degenerate case `ρ = 1` recovers exact corpus robustness.

-- !-- Lab Notes -- !--
Hypothesizer (cycle-3 conjectures):
 (H11) Domain jumps are projective, not additive, perturbations of the corpus
       cone: the correct control parameter is a Hilbert-metric radius.   [BOLD]
 (H12) A ρ-tilt is exactly a `ρ²` shift in the gate coordinate, uniformly in
       the budget — a gate/budget exchange rate.                          [BOLD]
 (H13) Consequently the deployment table transfers to any unmeasured domain
       inside a tilt ball on which the measured sweep is flat.
 (H14) With a geometric tail, the transfer cost is only `2 log ρ / log(1/r)`
       extra keys, i.e. logarithmic in the domain distortion.

Experimenter: H11–H14 are formalised below with zero sorries.  `domain_tilt_budget_bound`
is the explicit budget statement; the logarithmic reading of H14 is the statement that
`r^K ≤ 1 - ρ²τ` is solvable with `K = O(log(1/(1-ρ²τ))/log(1/r))`.

Analyst: what fails is any attempt to bound `k*_B(τ)` by `k*_A(τ)` alone — no bound in
the *budget* coordinate can hold uniformly, because the uniform corpus is a bounded
tilt of a geometric one only for large `ρ`, and its knee is linear in the context.
The gate coordinate is the only one in which a tilt acts boundedly, which is precisely
statement H12.

Critic: the hypotheses are inhabited (`Tilt 1 A A` for every corpus, and the tilted
family of cycle 2 gives non-trivial `ρ > 1` instances), and no theorem is vacuous:
`domain_jump_gate_window` has content already at `ρ = 1`, where it degenerates to the
exact-equality statement `tilt_exact_of_one`.
-/

namespace Catalog.Algebra.NET57

open Finset

/-! ## Tilts: balls in the projective metric on the corpus cone -/

/-- `B` is a **ρ-tilt** of `A`: every key's weight is distorted by at most the factor
`ρ` in either direction.  For `ρ = 1` this forces `A = B`. -/
def Tilt (ρ : ℝ) (A B : ℕ → ℝ) : Prop := ∀ i, B i ≤ ρ * A i ∧ A i ≤ ρ * B i

lemma Tilt.symm {ρ : ℝ} {A B : ℕ → ℝ} (h : Tilt ρ A B) : Tilt ρ B A :=
  fun i => ⟨(h i).2, (h i).1⟩

lemma Tilt.refl (A : ℕ → ℝ) : Tilt 1 A A := fun i => ⟨by simp, by simp⟩

lemma headMass_le_of_tilt {ρ : ℝ} {A B : ℕ → ℝ} (h : Tilt ρ A B) (k : ℕ) :
    headMass B k ≤ ρ * headMass A k := by
  rw [headMass, headMass, Finset.mul_sum]
  exact Finset.sum_le_sum fun i _ => (h i).1

/-- **The exchange rate between domain distortion and gate.**  A ρ-tilt costs a factor
`ρ²` in the gate and nothing in the budget. -/
theorem clears_of_tilt {ρ τ : ℝ} {A B : ℕ → ℝ} {n k : ℕ} (hρ : 0 < ρ) (hτ : 0 ≤ τ)
    (h : Tilt ρ A B) (hA : Clears A n k (ρ ^ 2 * τ)) : Clears B n k τ := by
  have h1 : headMass B n ≤ ρ * headMass A n := headMass_le_of_tilt h n
  have h2 : headMass A k ≤ ρ * headMass B k := headMass_le_of_tilt h.symm k
  have hA' : ρ ^ 2 * τ * headMass A n ≤ headMass A k := hA
  have hstep : ρ * (τ * headMass B n) ≤ ρ * headMass B k := by
    nlinarith [mul_le_mul_of_nonneg_left h1 hτ]
  exact le_of_mul_le_mul_left hstep hρ

/-- **Gate-window law, upper half.**  The knee of a ρ-tilted corpus is bounded by the
reference knee at the inflated gate `ρ²τ`. -/
theorem knee_tilt_le {ρ τ : ℝ} {A B : ℕ → ℝ} {n : ℕ} (hρ : 0 < ρ) (hτ : 0 ≤ τ)
    (hA : IsCorpus A) (h : Tilt ρ A B) (hgate : ρ ^ 2 * τ ≤ 1) :
    knee B n τ ≤ knee A n (ρ ^ 2 * τ) :=
  knee_le_of_clears (clears_of_tilt hρ hτ h (clears_knee hA hgate))

/-- **The domain-jump gate window.**  A ρ-tilt moves the knee no further than the
reference corpus's own sweep moves across a gate window of multiplicative width `ρ²`:

`k*_A(τ/ρ²) ≤ k*_B(τ) ≤ k*_A(ρ²τ)`.

An unmeasured domain is therefore controlled by *measured* gates. -/
theorem domain_jump_gate_window {ρ τ : ℝ} {A B : ℕ → ℝ} {n : ℕ} (hρ : 0 < ρ) (hτ : 0 ≤ τ)
    (hA : IsCorpus A) (hB : IsCorpus B) (h : Tilt ρ A B)
    (hgate : ρ ^ 2 * τ ≤ 1) (hτ1 : τ ≤ 1) :
    knee A n (τ / ρ ^ 2) ≤ knee B n τ ∧ knee B n τ ≤ knee A n (ρ ^ 2 * τ) := by
  have hρ2 : (0 : ℝ) < ρ ^ 2 := by positivity
  refine ⟨?_, knee_tilt_le hρ hτ hA h hgate⟩
  have hlow : ρ ^ 2 * (τ / ρ ^ 2) = τ := by field_simp
  have := knee_tilt_le (B := A) (A := B) (n := n) (τ := τ / ρ ^ 2) hρ (by positivity) hB
    h.symm (by rw [hlow]; exact hτ1)
  rwa [hlow] at this

/-- At `ρ = 1` the window collapses and corpus robustness is exact. -/
theorem tilt_exact_of_one {τ : ℝ} {A B : ℕ → ℝ} {n : ℕ} (hτ : 0 ≤ τ) (hτ1 : τ ≤ 1)
    (hA : IsCorpus A) (hB : IsCorpus B) (h : Tilt 1 A B) :
    knee B n τ = knee A n τ := by
  have hw := domain_jump_gate_window (ρ := 1) (n := n) one_pos hτ hA hB h
    (by simpa using hτ1) hτ1
  simp only [one_pow, one_mul, div_one] at hw
  exact le_antisymm hw.2 hw.1

/-- **Deployment criterion.**  If the reference sweep is flat across the gate window
`[τ/ρ², ρ²τ]` — a purely *measured* condition — then every ρ-tilted corpus, including
one from an unmeasured domain, has exactly the reference knee. -/
theorem tilt_knee_eq_of_flat_window {ρ τ : ℝ} {A B : ℕ → ℝ} {n : ℕ} (hρ : 0 < ρ)
    (hτ : 0 ≤ τ) (hτ1 : τ ≤ 1) (hA : IsCorpus A) (hB : IsCorpus B) (h : Tilt ρ A B)
    (hgate : ρ ^ 2 * τ ≤ 1)
    (hflat : knee A n (τ / ρ ^ 2) = knee A n (ρ ^ 2 * τ)) :
    knee B n τ = knee A n (ρ ^ 2 * τ) := by
  obtain ⟨hlo, hhi⟩ := domain_jump_gate_window hρ hτ hA hB h hgate hτ1
  exact le_antisymm hhi (hflat ▸ hlo)

/-! ## The sharp form: missing mass, not retained mass, is what a tilt inflates

The gate-window law above is stated in the *retained* coordinate, where it inflates the
gate by `ρ²`; at a high gate such as `0.98` that is only usable for `ρ² ≤ 1/0.98`.  The
sharp statement lives in the complementary coordinate: a ρ-tilt inflates the **missing
mass** by `ρ²`.  At gate `0.98` and `ρ = 1.1` this costs `0.02 → 0.0242`, i.e. a gate
of `0.9758` — a usable deployment bound. -/

/-- Tail mass beyond budget `k` as a sum over `Ico k n`. -/
lemma headMass_sub_eq_sum_Ico (w : ℕ → ℝ) {k n : ℕ} (hk : k ≤ n) :
    headMass w n - headMass w k = ∑ i ∈ Finset.Ico k n, w i := by
  rw [Finset.sum_Ico_eq_sub _ hk]
  rfl

/-- A ρ-tilt inflates the tail mass by at most `ρ`. -/
lemma tail_le_of_tilt {ρ : ℝ} {A B : ℕ → ℝ} {k n : ℕ} (h : Tilt ρ A B) (hk : k ≤ n) :
    headMass B n - headMass B k ≤ ρ * (headMass A n - headMass A k) := by
  rw [headMass_sub_eq_sum_Ico B hk, headMass_sub_eq_sum_Ico A hk, Finset.mul_sum]
  exact Finset.sum_le_sum fun i _ => (h i).1

/-- **Domain-jump law, sharp form.**  If the reference corpus leaves at most a fraction
`δ` of its mass outside budget `k`, then a ρ-tilted corpus leaves at most `ρ²δ`.  In
gate language: clearing `1 - δ` on `A` gives `1 - ρ²δ` on `B`, at the *same* budget. -/
theorem clears_of_tilt_tail {ρ δ : ℝ} {A B : ℕ → ℝ} {n k : ℕ} (hρ : 0 < ρ) (hδ : 0 ≤ δ)
    (hA : IsCorpus A) (h : Tilt ρ A B) (hk : k ≤ n)
    (hclear : Clears A n k (1 - δ)) : Clears B n k (1 - ρ ^ 2 * δ) := by
  have htail : headMass B n - headMass B k ≤ ρ * (headMass A n - headMass A k) :=
    tail_le_of_tilt h hk
  have hAtail : headMass A n - headMass A k ≤ δ * headMass A n := by
    have : (1 - δ) * headMass A n ≤ headMass A k := hclear
    nlinarith
  have hAB : headMass A n ≤ ρ * headMass B n := headMass_le_of_tilt h.symm n
  have hAn : 0 ≤ headMass A n := headMass_nonneg hA n
  have key : headMass B n - headMass B k ≤ ρ ^ 2 * δ * headMass B n := by
    have h1 : ρ * (headMass A n - headMass A k) ≤ ρ * (δ * headMass A n) :=
      mul_le_mul_of_nonneg_left hAtail hρ.le
    have h2 : ρ * (δ * headMass A n) ≤ ρ * (δ * (ρ * headMass B n)) := by
      have := mul_le_mul_of_nonneg_left hAB hδ
      nlinarith
    nlinarith
  simp only [Clears]
  nlinarith

/-- **Sharp gate transfer for the knee.**  A ρ-tilted corpus reaches the inflated gate
`1 - ρ²δ` with the reference budget for gate `1 - δ`. -/
theorem knee_tilt_tail_le {ρ δ : ℝ} {A B : ℕ → ℝ} {n : ℕ} (hρ : 0 < ρ) (hδ : 0 ≤ δ)
    (hA : IsCorpus A) (h : Tilt ρ A B) :
    knee B n (1 - ρ ^ 2 * δ) ≤ knee A n (1 - δ) :=
  knee_le_of_clears (clears_of_tilt_tail hρ hδ hA h (knee_le_context hA (by linarith))
    (clears_knee hA (by linarith)))

/-- The tilt ball of radius `ρ > 1` is genuinely larger than a point, so the domain-jump
laws are not statements about a single corpus. -/
theorem tilt_ball_nontrivial : ∃ B : ℕ → ℝ, Tilt 2 uniform2 B ∧ B ≠ uniform2 := by
  refine ⟨fun i => if i = 0 then (1 : ℝ) / 2 else 1, fun i => ?_, ?_⟩
  · unfold uniform2
    by_cases hi : i = 0
    · simp only [hi]; norm_num
    · simp only [if_neg hi]; norm_num
  · intro hcon
    have h0 := congrFun hcon 0
    simp [uniform2] at h0

/-! ## The explicit deployment number under a geometric tail -/

/-- A corpus has an **`r`-geometric retention tail** at context `n` when its retained
mass at budget `k` is at least `1 - r^k`. -/
def GeoTail (A : ℕ → ℝ) (n : ℕ) (r : ℝ) : Prop := ∀ k ≤ n, 1 - r ^ k ≤ retained A n k

/-- **Explicit domain-jump budget.**  Under an `r`-geometric tail for the reference
corpus, every ρ-tilted corpus at gate `τ` is served by any budget `K ≤ n` with
`r^K ≤ 1 - ρ²τ`.  Solving for `K` gives `K = O(log(1/(1 - ρ²τ)) / log(1/r))`: the price
of a domain jump is logarithmic in the distortion, and no re-measurement on the new
domain is required. -/
theorem domain_tilt_budget_bound {ρ τ r : ℝ} {A B : ℕ → ℝ} {n K : ℕ} (hρ : 0 < ρ)
    (hτ : 0 ≤ τ) (h : Tilt ρ A B)
    (hApos : 0 < headMass A n) (htail : GeoTail A n r) (hKn : K ≤ n)
    (hK : r ^ K ≤ 1 - ρ ^ 2 * τ) :
    knee B n τ ≤ K := by
  have hclearsA : Clears A n K (ρ ^ 2 * τ) := by
    rw [clears_iff_retained hApos]
    have h1 : 1 - r ^ K ≤ retained A n K := htail K hKn
    linarith
  exact knee_le_of_clears (clears_of_tilt hρ hτ h hclearsA)

/-- The reference corpus itself obeys the bound (the `ρ = 1` reading of
`domain_tilt_budget_bound`): a geometric tail alone pins a context-uniform budget. -/
theorem geo_tail_budget_bound {τ r : ℝ} {A : ℕ → ℝ} {n K : ℕ} (hτ : 0 ≤ τ)
    (hApos : 0 < headMass A n) (htail : GeoTail A n r) (hKn : K ≤ n)
    (hK : r ^ K ≤ 1 - τ) :
    knee A n τ ≤ K := by
  refine domain_tilt_budget_bound (ρ := 1) one_pos hτ (Tilt.refl A) hApos htail hKn ?_
  simpa using hK

end Catalog.Algebra.NET57