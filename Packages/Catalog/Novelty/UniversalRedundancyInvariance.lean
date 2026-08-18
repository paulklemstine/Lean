/-
# The price of universality, VIII: an invariance theorem with an explicit price

Algorithmic information theory's invariance theorem says that two universal
machines differ by an additive constant, but the constant is opaque.  In the
statistical setting the constant is *computable*: if `P' ⊆ P` are classes of
sources and `U'`, `U` are their normalised maximum likelihood codes, then on
every message the specialised code `U'` beats the more general code `U` by at
most

  `log₂ S(P) − log₂ S(P')`  bits,

i.e. exactly the ratio of the two Shtarkov normalisers, and this is **attained**
on any message whose maximum likelihood is achieved inside the subclass
(`nml_excess_eq`).  A concrete witness — the `m` deterministic sources with the
one-element subclass — realises the full `log₂ m` bits
(`indicator_invariance_price`), so the bound is not vacuous.

Reading this back into the research programme: **the entire benefit of a
specialised decompressor is the logarithm of how much model class it throws
away.**  Nothing else about the specialisation matters.
-/
import Novelty.UniversalRedundancySharpness

namespace PriceOfUniversality

open Finset Real

section Invariance

variable {A : Type*} [Fintype A] [Nonempty A]
variable {Θ Θ' : Type*} [Fintype Θ] [Nonempty Θ] [Fintype Θ'] [Nonempty Θ']

/-- The subclass of `p` obtained by reindexing along `e`: the sources that the
specialised decompressor still has to serve. -/
def subClass (p : Θ → A → ℝ) (e : Θ' → Θ) : Θ' → A → ℝ := fun t => p (e t)

omit [Nonempty A] [Fintype Θ] [Nonempty Θ] [Fintype Θ'] [Nonempty Θ'] in
theorem subClass_isPMF {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) (e : Θ' → Θ) (t : Θ') :
    IsPMF (subClass p e t) := hp (e t)

omit [Fintype A] [Nonempty A] in
/-- Maximum likelihood is monotone under enlarging the class. -/
theorem maxLik_subClass_le (p : Θ → A → ℝ) (e : Θ' → Θ) (a : A) :
    maxLik (subClass p e) a ≤ maxLik p a :=
  (Finset.sup'_le_iff univ_nonempty _).2 fun t _ => le_maxLik p (e t) a

omit [Nonempty A] in
/-- **Monotonicity of the Shtarkov sum**: a bigger model class has a bigger
normaliser, hence a bigger price of universality. -/
theorem shtarkov_subClass_le (p : Θ → A → ℝ) (e : Θ' → Θ) :
    shtarkov (subClass p e) ≤ shtarkov p := by
  simp only [shtarkov]
  exact Finset.sum_le_sum fun a _ => maxLik_subClass_le p e a

omit [Nonempty A] in
/-- **The invariance theorem with an explicit price.**  On every message the
specialised NML code is at most `log₂ (S(P) / S(P'))` bits shorter than the more
general one. -/
theorem nml_excess_le {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) (e : Θ' → Θ) (a : A)
    (hpos : 0 < maxLik (subClass p e) a) :
    logb 2 (nml (subClass p e) a) - logb 2 (nml p a)
      ≤ logb 2 (shtarkov p) - logb 2 (shtarkov (subClass p e)) := by
  have hsub : 0 < shtarkov (subClass p e) := shtarkov_pos (subClass_isPMF hp e)
  have hS : 0 < shtarkov p := shtarkov_pos hp
  have hpos2 : 0 < maxLik p a := lt_of_lt_of_le hpos (maxLik_subClass_le p e a)
  have hml : logb 2 (maxLik (subClass p e) a) ≤ logb 2 (maxLik p a) :=
    Real.logb_le_logb_of_le (by norm_num) hpos (maxLik_subClass_le p e a)
  simp only [nml]
  rw [Real.logb_div (ne_of_gt hpos) (ne_of_gt hsub),
    Real.logb_div (ne_of_gt hpos2) (ne_of_gt hS)]
  linarith

omit [Nonempty A] in
/-- **Sharpness of the invariance price.**  On a message whose maximum
likelihood is already attained inside the subclass, the specialised code saves
exactly `log₂ (S(P) / S(P'))` bits — no more and no less. -/
theorem nml_excess_eq {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) (e : Θ' → Θ) (a : A)
    (hpos : 0 < maxLik (subClass p e) a)
    (heq : maxLik (subClass p e) a = maxLik p a) :
    logb 2 (nml (subClass p e) a) - logb 2 (nml p a)
      = logb 2 (shtarkov p) - logb 2 (shtarkov (subClass p e)) := by
  have hsub : 0 < shtarkov (subClass p e) := shtarkov_pos (subClass_isPMF hp e)
  have hS : 0 < shtarkov p := shtarkov_pos hp
  have hpos2 : 0 < maxLik p a := heq ▸ hpos
  simp only [nml]
  rw [Real.logb_div (ne_of_gt hpos) (ne_of_gt hsub),
    Real.logb_div (ne_of_gt hpos2) (ne_of_gt hS), heq]
  ring

end Invariance

/-! ## A one-source subclass, and the exact value of specialising -/

section Singleton

variable {A : Type*} [Fintype A] [Nonempty A]
variable {Θ : Type*} [Fintype Θ] [Nonempty Θ]

omit [Fintype A] [Nonempty A] in
theorem maxLik_unique [Unique Θ] (p : Θ → A → ℝ) (a : A) : maxLik p a = p default a := by
  obtain ⟨θ, hθ⟩ := exists_eq_maxLik p a
  rw [hθ, Subsingleton.elim θ (default : Θ)]

omit [Nonempty A] in
/-- A one-element class pays no price of universality: its Shtarkov sum is `1`. -/
theorem shtarkov_unique [Unique Θ] {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) :
    shtarkov p = 1 := by
  calc shtarkov p = ∑ a, p default a := Finset.sum_congr rfl fun a _ => maxLik_unique p a
    _ = 1 := (hp default).total

end Singleton

variable {m : ℕ}

/-- The one-source specialisation of the class of `m` deterministic sources. -/
noncomputable def indicatorSub (m : ℕ) [NeZero m] : Fin 1 → Fin m → ℝ :=
  subClass (indicatorClass m) (fun _ => (0 : Fin m))

theorem shtarkov_indicatorSub [NeZero m] : shtarkov (indicatorSub m) = 1 :=
  shtarkov_unique (fun t => subClass_isPMF (fun θ => indicatorClass_isPMF θ) _ t)

theorem shtarkov_indicatorClass [NeZero m] : shtarkov (indicatorClass m) = m := by
  rw [shtarkov_disjointSupports (fun θ => indicatorClass_isPMF θ) indicatorClass_disjoint,
    Fintype.card_fin]

theorem maxLik_indicatorSub_zero [NeZero m] : maxLik (indicatorSub m) (0 : Fin m) = 1 := by
  rw [indicatorSub, maxLik_unique]
  norm_num [subClass, indicatorClass]

theorem maxLik_indicatorClass_zero [NeZero m] : maxLik (indicatorClass m) (0 : Fin m) = 1 := by
  refine le_antisymm ((Finset.sup'_le_iff univ_nonempty _).2 fun θ _ => ?_) ?_
  · simp only [indicatorClass]; split <;> norm_num
  · have := le_maxLik (indicatorClass m) (0 : Fin m) (0 : Fin m)
    simpa [indicatorClass] using this

/-- **The invariance price is attained.**  Specialising the class of `m`
deterministic sources to a single one of them saves exactly `log₂ m` bits on the
message that source emits: the whole cost of naming the source, and nothing
more. -/
theorem indicator_invariance_price [NeZero m] :
    logb 2 (nml (indicatorSub m) (0 : Fin m)) - logb 2 (nml (indicatorClass m) (0 : Fin m))
      = logb 2 m := by
  have hbase :
      logb 2 (nml (indicatorSub m) (0 : Fin m)) - logb 2 (nml (indicatorClass m) (0 : Fin m))
        = logb 2 (shtarkov (indicatorClass m)) - logb 2 (shtarkov (indicatorSub m)) := by
    refine nml_excess_eq (fun θ => indicatorClass_isPMF θ) _ (0 : Fin m) ?_ ?_
    · rw [show subClass (indicatorClass m) (fun _ : Fin 1 => (0 : Fin m)) = indicatorSub m from rfl,
        maxLik_indicatorSub_zero]
      norm_num
    · rw [show subClass (indicatorClass m) (fun _ : Fin 1 => (0 : Fin m)) = indicatorSub m from rfl,
        maxLik_indicatorSub_zero, maxLik_indicatorClass_zero]
  rw [hbase, shtarkov_indicatorSub, shtarkov_indicatorClass]
  simp

end PriceOfUniversality