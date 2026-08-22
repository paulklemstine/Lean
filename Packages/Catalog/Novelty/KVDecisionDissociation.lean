import Mathlib

/-!
# Decision–vector dissociation for attention scores (NET-51, Part A)

This file formalises the *structural* content of the NET-51 measurement
**THE-KV-CORE-IS-SHARED-THE-TAIL-IS-PERSONAL**.

The empirical situation was: two fine-tunes of the same base transformer keep
cosine-similar key/value caches at *every* layer (`cosK ≥ 0.976`, mean `0.990`),
yet in the last two layers (L22/L23) their top-1 attention decisions agree only
`0.568` / `0.627` of the time.  The slogan extracted from that measurement is

> *vector similarity does not bound functional divergence.*

Here we prove that this is not an artefact of one model pair but a theorem
about score vectors:

* `strictTop_of_margin` — the *correct* stability certificate is a **margin**
  (gap) condition: if the top-1 gap of `u` exceeds `2ε` and `u` and `v` differ
  by at most `ε` coordinatewise, then `v` makes the same decision.
* `margin_factor_two_is_sharp` — the constant `2` cannot be improved: with gap
  exactly `2ε` a perturbation of size `ε` can already destroy the decision.
* `cosine_near_one_decision_flip` — for **every** `ε > 0` there are two score
  vectors with cosine similarity `> 1 - ε` whose top-1 decisions differ.  So no
  function of the cosine alone can lower-bound decision agreement: this is the
  NET-51 dissociation, in its sharpest possible form.
* `strictTop_le_sqrt_collision` / `diffuse_decision_is_fragile` — the
  quantitative reason the *diffuse* tail is where decisions break: a small
  collision mass `∑ p k ^ 2` forces a small top-1 gap, hence a flip under an
  arbitrarily small perturbation.

Nothing here is asymptotic or approximate: all constants are explicit.
-/

namespace Catalog.Novelty.KVDecisionDissociation

open Finset

/-- `i` is the strict top-1 choice of the score vector `u`
(the "attention decision" of `u`). -/
def IsStrictTop {n : ℕ} (u : Fin n → ℝ) (i : Fin n) : Prop := ∀ j, j ≠ i → u j < u i

/-- A vector has *no* decision when two coordinates tie at the top. -/
def NoStrictTop {n : ℕ} (u : Fin n → ℝ) : Prop := ∀ i, ¬ IsStrictTop u i

/-! ### 1. The correct stability certificate: margin, not cosine -/

/-- **Margin stability.**  If the top-1 gap of `u` at `i` exceeds `2ε` and `v`
differs from `u` by at most `ε` in every coordinate, then `v` makes the same
top-1 decision.  This is the only sound "decisions agree" certificate. -/
theorem strictTop_of_margin {n : ℕ} (u v : Fin n → ℝ) (i : Fin n) (eps : ℝ)
    (hmargin : ∀ j, j ≠ i → 2 * eps < u i - u j)
    (hclose : ∀ j, |u j - v j| ≤ eps) : IsStrictTop v i := by
  intro j hj
  have h1 := hmargin j hj
  have h2 := abs_le.1 (hclose j)
  have h3 := abs_le.1 (hclose i)
  linarith [h2.1, h2.2, h3.1, h3.2]

/-- **Sharpness of the factor `2`.**  With a top-1 gap of exactly `2ε` a
coordinatewise `ε`-perturbation can already erase the decision entirely.
Hence `strictTop_of_margin` is optimal. -/
theorem margin_factor_two_is_sharp (eps : ℝ) (heps : 0 < eps) :
    ∃ u v : Fin 2 → ℝ,
      (∀ j, j ≠ (0 : Fin 2) → u 0 - u j = 2 * eps) ∧
      (∀ j, |u j - v j| ≤ eps) ∧
      IsStrictTop u 0 ∧ NoStrictTop v := by
  refine ⟨![2 * eps, 0], ![eps, eps], ?_, ?_, ?_, ?_⟩
  · intro j hj
    fin_cases j
    · exact absurd rfl hj
    · simp
  · intro j
    fin_cases j
    · show |2 * eps - eps| ≤ eps
      rw [show 2 * eps - eps = eps by ring, abs_of_pos heps]
    · show |(0 : ℝ) - eps| ≤ eps
      rw [abs_le]; constructor <;> linarith
  · intro j hj
    fin_cases j
    · exact absurd rfl hj
    · simpa using by linarith
  · intro i hi
    fin_cases i
    · have := hi 1 (by decide); simp at this
    · have := hi 0 (by decide); simp at this

/-! ### 2. Cosine similarity: the dissociation -/

/-- Euclidean inner product of two score vectors. -/
noncomputable def dotP {n : ℕ} (u v : Fin n → ℝ) : ℝ := ∑ i, u i * v i

/-- Euclidean norm of a score vector. -/
noncomputable def nrmP {n : ℕ} (u : Fin n → ℝ) : ℝ := Real.sqrt (∑ i, u i ^ 2)

/-- Cosine similarity, the quantity reported as `cosK` / `cosV` in NET-51. -/
noncomputable def cosSim {n : ℕ} (u v : Fin n → ℝ) : ℝ := dotP u v / (nrmP u * nrmP v)

/-- The *flip pair* at scale `t`: `(1+t, 1)` versus `(1, 1+t)`.
Its cosine similarity is exactly `(2 + 2t)/(t² + 2t + 2) = 1 - t²/(t²+2t+2)`. -/
theorem cosSim_flipPair (t : ℝ) :
    cosSim ![1 + t, 1] ![1, 1 + t] = (2 + 2 * t) / (t ^ 2 + 2 * t + 2) := by
  have e1 : (1 + t) ^ 2 + (1 : ℝ) ^ 2 = t ^ 2 + 2 * t + 2 := by ring
  have e2 : (1 : ℝ) ^ 2 + (1 + t) ^ 2 = t ^ 2 + 2 * t + 2 := by ring
  have hs : (0 : ℝ) ≤ t ^ 2 + 2 * t + 2 := by nlinarith [sq_nonneg (t + 1)]
  simp only [cosSim, dotP, nrmP, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one,
    e1, e2]
  rw [Real.mul_self_sqrt hs]
  ring_nf

/-- For `t > 0` the flip pair has cosine similarity at least `1 - t/2`. -/
theorem cosSim_flipPair_lower (t : ℝ) (ht : 0 < t) :
    1 - t / 2 ≤ cosSim ![1 + t, 1] ![1, 1 + t] := by
  rw [cosSim_flipPair]
  rw [le_div_iff₀ (by nlinarith : (0:ℝ) < t ^ 2 + 2 * t + 2)]
  nlinarith [sq_nonneg t, mul_pos ht ht, sq_nonneg (t - 1)]

/-- **The NET-51 dissociation.**  For every `ε > 0` there are two score vectors
whose cosine similarity exceeds `1 - ε` but whose top-1 attention decisions are
*different*.  Consequently no monotone function of the cosine similarity can be
a lower bound for top-1 decision agreement: the observed
`cos = 0.983` with agreement `0.568` at layer 22 is structurally possible. -/
theorem cosine_near_one_decision_flip (eps : ℝ) (heps : 0 < eps) :
    ∃ u v : Fin 2 → ℝ,
      1 - eps < cosSim u v ∧ IsStrictTop u 0 ∧ IsStrictTop v 1 := by
  set t : ℝ := eps with ht
  have ht0 : 0 < t := heps
  refine ⟨![1 + t, 1], ![1, 1 + t], ?_, ?_, ?_⟩
  · have h := cosSim_flipPair_lower t ht0
    have : 1 - eps < 1 - t / 2 := by rw [ht]; linarith
    linarith
  · intro j hj
    fin_cases j
    · exact absurd rfl hj
    · simpa using by linarith
  · intro j hj
    fin_cases j
    · simpa using by linarith
    · exact absurd rfl hj

/-- Quantitative companion: in the flip pair the coordinatewise perturbation is
exactly `t` while the top-1 gap is also `t`, i.e. the flip happens *exactly* at
the boundary allowed by `strictTop_of_margin`. -/
theorem flipPair_perturbation (t : ℝ) (ht : 0 < t) :
    (∀ j, |(![1 + t, 1] : Fin 2 → ℝ) j - (![1, 1 + t] : Fin 2 → ℝ) j| ≤ t) ∧
      (![1 + t, 1] : Fin 2 → ℝ) 0 - (![1 + t, 1] : Fin 2 → ℝ) 1 = t := by
  constructor
  · intro j
    fin_cases j <;> simp [abs_of_nonneg, abs_of_nonpos, ht.le]
  · simp

/-! ### 3. Why the *diffuse* tail is the fragile region -/

/-- Any coordinate of a nonnegative vector is bounded by the square root of its
collision mass `∑ p k ^ 2`.  For an attention distribution this says: diffuse
(low-collision) attention has a small top weight. -/
theorem strictTop_le_sqrt_collision {n : ℕ} (p : Fin n → ℝ) (hp : ∀ k, 0 ≤ p k)
    (i : Fin n) : p i ≤ Real.sqrt (∑ k, p k ^ 2) := by
  have h1 : p i ^ 2 ≤ ∑ k, p k ^ 2 :=
    Finset.single_le_sum (f := fun k => p k ^ 2) (fun k _ => sq_nonneg (p k)) (mem_univ i)
  calc p i = Real.sqrt (p i ^ 2) := (Real.sqrt_sq (hp i)).symm
    _ ≤ Real.sqrt (∑ k, p k ^ 2) := Real.sqrt_le_sqrt h1

/-- **Diffuse attention is decision-fragile.**  If an attention distribution `p`
has collision mass `C = ∑ p k ^ 2` and currently decides `i`, then for every
`η > 0` there is a perturbation of size at most `√C + η` (coordinatewise) that
moves the decision to *any* prescribed other index `j`.  Since `√C` is small in
the diffuse tail, a fine-tune delta of that size — well inside the measured
`relK ≈ 0.16` — suffices to flip the decision, while the cosine similarity
stays near `1` by `cosine_near_one_decision_flip`. -/
theorem diffuse_decision_is_fragile {n : ℕ} (p : Fin n → ℝ) (hp : ∀ k, 0 ≤ p k)
    (i j : Fin n) (hij : j ≠ i) (htop : IsStrictTop p i) (eta : ℝ) (heta : 0 < eta) :
    ∃ q : Fin n → ℝ,
      (∀ k, |p k - q k| ≤ Real.sqrt (∑ k, p k ^ 2) + eta) ∧ IsStrictTop q j := by
  refine ⟨Function.update p j (p i + eta), ?_, ?_⟩
  · intro k
    by_cases hk : k = j
    · subst hk
      have hpk : p k < p i := htop k hij
      have h1 : |p k - (p i + eta)| = p i + eta - p k := by
        rw [abs_of_nonpos (by linarith)]; ring
      have h2 : p i ≤ Real.sqrt (∑ k, p k ^ 2) := strictTop_le_sqrt_collision p hp i
      have h3 : 0 ≤ p k := hp k
      simp only [Function.update_self, h1]
      linarith
    · have hnn : 0 ≤ Real.sqrt (∑ k, p k ^ 2) := Real.sqrt_nonneg _
      simp [Function.update_of_ne hk]
      linarith
  · intro k hk
    have hle : p k ≤ p i := by
      by_cases h : k = i
      · exact le_of_eq (by rw [h])
      · exact (htop k h).le
    simp only [Function.update_self, Function.update_of_ne hk]
    linarith

/-! ### 4. The two halves put together

`core_layers_agree` is the positive half (a margin certificate makes *all*
per-layer decisions agree, which is what the 22 shared layers exhibit) and
`cosine_near_one_decision_flip` is the negative half (cosine alone certifies
nothing, which is what the tail exhibits). -/

/-- If at every layer the two models' score vectors differ by at most `ε`
coordinatewise and the reference model has top-1 gap `> 2ε`, then the two
models agree on the decision at *every* layer. -/
theorem core_layers_agree {L n : ℕ} (u v : Fin L → Fin n → ℝ) (i : Fin L → Fin n)
    (eps : ℝ) (hmargin : ∀ l j, j ≠ i l → 2 * eps < u l (i l) - u l j)
    (hclose : ∀ l j, |u l j - v l j| ≤ eps) :
    ∀ l, IsStrictTop (u l) (i l) ∧ IsStrictTop (v l) (i l) := by
  intro l
  refine ⟨?_, strictTop_of_margin (u l) (v l) (i l) eps (hmargin l) (hclose l)⟩
  intro j hj
  have h0 : (0 : ℝ) ≤ eps := le_trans (abs_nonneg _) (hclose l j)
  have := hmargin l j hj
  linarith

end Catalog.Novelty.KVDecisionDissociation