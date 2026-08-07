import Novelty.DiophantineLatticeExactOrder

/-!
# Cycle 7: the parity criterion for shifted theta coefficients

Cycle 2 proved that all coefficients of the shifted theta series of `x ↦ Q(x - v/2)` are even
when `v` is a *shortest* vector (`halfPt_multiplicity_even`).  Conjecture 2 of
`FUTURE_DIRECTIONS.md` asserted that evenness is in fact an exact criterion:

  `(∀ c, r_t(c) is even)  ⟺  2t ∈ L and t ∉ L`.

This file proves the `⟸` direction **in full generality** — for an arbitrary rational
positive-semidefinite-free setting, in fact for an arbitrary rational matrix `B`, with no
minimality, positivity or symmetry hypothesis at all — and settles the `⟹` direction in
rank one, where the criterion becomes a theorem.

* `halfPt_multiplicity_even_of_primitive` : the hypothesis "`v` is shortest" in
  `halfPt_multiplicity_even` is superfluous; all that the antipodal involution `m ↦ v - m`
  needs is `v ∉ 2L`.
* `two_torsion_multiplicity_even` : consequently every coefficient is even whenever `2t ∈ L`
  and `t ∉ L`.  This closes the `⟸` half of Conjecture 2.
* `rank_one_multiplicity_odd_of_not_half` : in rank one, if `2t ∉ ℤ` then the coefficient at
  `c = t²` equals `1`, so it is odd.
* `rank_one_multiplicity_even_iff` : **Conjecture 2 in rank one**, an exact `iff`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): evenness of the shifted theta coefficients is equivalent to the
existence of the antipodal symmetry, i.e. to `2t ∈ L, t ∉ L`; no other mechanism can force it.
Experiment (Experimenter): stripping `hv : Q(v) = λ₁` from `halfPt_multiplicity_even` leaves a
proof that uses only `v - 2m ≠ 0`, so the `⟸` direction holds for every `2`-torsion shift.
For `⟹`, the rank-one computation is decisive: `(t - m)² = (t - m')²` with `m ≠ m'` forces
`m + m' = 2t`, so `2t ∉ ℤ` makes *every* coefficient at most `1`, and the coefficient at
`c = t²` is exactly `1`.
Analysis (Analyst): the obstruction to a rank-`n` proof of `⟹` is that a coefficient can be
even "by accident" (two unrelated pairs of lattice points at the same distance); the rank-one
argument works because the fibre of `x ↦ Q(x)` over `c` has at most two points.  So the
general `⟹` is "true but hard", needing a global count rather than a fibrewise one.
Critique (Critic): `rank_one_multiplicity_even_iff` is an honest `iff` with no side condition,
and its two halves are proved by genuinely different arguments (involution vs. fibre count);
`two_torsion_multiplicity_even` is strictly stronger than the cycle-2 theorem, which it
re-derives (`halfPt_multiplicity_even_reproved`).
Synthesis (PI): the parity of the shifted theta series is an exact `2`-torsion criterion in
rank one, and the sufficiency half holds in every rank.
-/

namespace DiophantineLattice

open Finset

variable {n : ℕ}

/-! ## Evenness without minimality -/

/-- **Even multiplicity, general form.**  If `v` is not twice a lattice vector then every
coefficient of the theta series of `x ↦ Q(x - v/2)` is even.  No positivity, symmetry or
minimality assumption on `B` or `v` is needed: the antipodal involution `m ↦ v - m` is a
fixed-point-free symmetry of each level set. -/
theorem halfPt_multiplicity_even_of_primitive (B : Matrix (Fin n) (Fin n) ℚ) {v : Fin n → ℤ}
    (hv2 : ∀ m : Fin n → ℤ, (fun i => v i - 2 * m i) ≠ 0) (c : ℚ) (S : Finset (Fin n → ℤ))
    (hS : ∀ m : Fin n → ℤ, m ∈ S ↔ form B (fun i => halfPt v i - emb m i) = c) :
    Even S.card := by
  classical
  set g : (Fin n → ℤ) → (Fin n → ℤ) := fun m => fun j => v j - m j with hg
  have hgmem : ∀ m ∈ S, g m ∈ S := by
    intro m hm
    rw [hS] at hm ⊢
    rw [halfPt_antipode_form]
    exact hm
  have hginv : ∀ m, g (g m) = m := by
    intro m; funext j; simp [hg]
  have hgfix : ∀ m ∈ S, g m ≠ m := by
    intro m _ hfix
    have hvm : ∀ i, v i - 2 * m i = 0 := by
      intro i
      have : (g m) i = m i := by rw [hfix]
      simp only [hg] at this
      omega
    exact hv2 m (funext hvm)
  have hsum : ∑ _x ∈ S, (1 : ZMod 2) = 0 :=
    Finset.sum_involution (fun a _ => g a) (fun a _ => by decide)
      (fun a ha _ => hgfix a ha) (fun a ha => hgmem a ha) (fun a _ => hginv a)
  rw [Finset.sum_const, nsmul_eq_mul, mul_one] at hsum
  exact ZMod.natCast_eq_zero_iff_even.mp hsum

/-- A `2`-torsion shift is literally half of a lattice vector. -/
lemma eq_halfPt_of_two {t : Fin n → ℚ} {v : Fin n → ℤ} (hv : ∀ i, (2 : ℚ) * t i = (v i : ℚ)) :
    t = halfPt v := by
  funext i
  show t i = (v i : ℚ) / 2
  linarith [hv i]

/-- A `2`-torsion shift outside the lattice has a primitive numerator. -/
lemma two_torsion_primitive {t : Fin n → ℚ} {v : Fin n → ℤ}
    (hv : ∀ i, (2 : ℚ) * t i = (v i : ℚ)) (hnl : ∀ k : Fin n → ℤ, t ≠ emb k) (m : Fin n → ℤ) :
    (fun i => v i - 2 * m i) ≠ 0 := by
  intro h
  refine hnl m ?_
  funext i
  have hi : v i - 2 * m i = 0 := by
    have : (fun i => v i - 2 * m i) i = (0 : Fin n → ℤ) i := by rw [h]
    simpa using this
  have hq : (v i : ℚ) = 2 * (m i : ℚ) := by
    have hcast : ((v i - 2 * m i : ℤ) : ℚ) = 0 := by exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hi
    push_cast at hcast
    linarith
  have := hv i
  rw [hq] at this
  show t i = ((m i : ℤ) : ℚ)
  linarith

/-- **Conjecture 2, sufficiency (all ranks).**  If `2t` is a lattice vector and `t` is not,
then every coefficient of the shifted theta series of `x ↦ Q(x - t)` is even. -/
theorem two_torsion_multiplicity_even (B : Matrix (Fin n) (Fin n) ℚ) {t : Fin n → ℚ}
    {v : Fin n → ℤ} (hv : ∀ i, (2 : ℚ) * t i = (v i : ℚ)) (hnl : ∀ k : Fin n → ℤ, t ≠ emb k)
    (c : ℚ) (S : Finset (Fin n → ℤ))
    (hS : ∀ m : Fin n → ℤ, m ∈ S ↔ form B (fun i => t i - emb m i) = c) :
    Even S.card := by
  have hprim := two_torsion_primitive hv hnl
  rw [eq_halfPt_of_two hv] at hS
  exact halfPt_multiplicity_even_of_primitive B hprim c S hS

/-- The cycle-2 theorem is the special case of a shortest vector: a shortest vector is
primitive, hence its half has only even theta coefficients. -/
theorem halfPt_multiplicity_even_reproved {B : Matrix (Fin n) (Fin n) ℚ} (hpd : PosDef B)
    {lam : ℚ} (h : IsMinEnergy B lam) {v : Fin n → ℤ} (hv : form B (emb v) = lam) (c : ℚ)
    (S : Finset (Fin n → ℤ))
    (hS : ∀ m : Fin n → ℤ, m ∈ S ↔ form B (fun i => halfPt v i - emb m i) = c) :
    Even S.card := by
  obtain ⟨⟨w, hw, hwlam⟩, hmin⟩ := h
  have hpos : 0 < lam := by rw [← hwlam]; exact hpd _ (emb_ne_zero hw)
  exact halfPt_multiplicity_even_of_primitive B (sub_two_smul_ne_zero hpos hmin hv) c S hS

/-! ## Rank one: the criterion is exact -/

/-- In rank one every function is determined by its value at `0`. -/
lemma fin_one_ext {α : Type*} {f g : Fin 1 → α} (h : f 0 = g 0) : f = g := by
  funext i
  have : i = 0 := Subsingleton.elim i 0
  rw [this, h]

/-- **Rank-one fibre count.**  If `2t ∉ ℤ` then the level set of `x ↦ (x - t)²` at the value
`t²` is the single point `0`; in particular that coefficient is odd. -/
theorem rank_one_multiplicity_odd_of_not_half {t : Fin 1 → ℚ}
    (h2 : ∀ k : Fin 1 → ℤ, (fun i => (2 : ℚ) * t i) ≠ emb k) :
    ∃ (c : ℚ) (S : Finset (Fin 1 → ℤ)),
      (∀ m : Fin 1 → ℤ, m ∈ S ↔ form (1 : Matrix (Fin 1) (Fin 1) ℚ)
        (fun i => t i - emb m i) = c) ∧ ¬ Even S.card := by
  classical
  refine ⟨(t 0) ^ 2, {0}, ?_, ?_⟩
  · intro m
    rw [Finset.mem_singleton, form_one]
    rw [Finset.sum_eq_single (0 : Fin 1) (fun b _ hb => absurd (Subsingleton.elim b 0) hb)
      (fun hb => absurd (Finset.mem_univ _) hb)]
    simp only [emb_apply]
    constructor
    · rintro rfl
      simp
    · intro h
      have hfac : (m 0 : ℚ) * ((m 0 : ℚ) - 2 * t 0) = 0 := by nlinarith [h]
      rcases mul_eq_zero.mp hfac with h0 | h0
      · refine fin_one_ext ?_
        have : (m 0 : ℚ) = ((0 : ℤ) : ℚ) := by push_cast; linarith
        exact_mod_cast this
      · exfalso
        refine h2 m (fin_one_ext ?_)
        simp only [emb_apply]
        linarith
  · simp

/-- **Conjecture 2 in rank one.**  For the standard form on `ℤ`, all coefficients of the
shifted theta series of `x ↦ (x - t)²` are even **iff** `2t` is an integer and `t` is not. -/
theorem rank_one_multiplicity_even_iff (t : Fin 1 → ℚ) :
    (∀ (c : ℚ) (S : Finset (Fin 1 → ℤ)),
        (∀ m : Fin 1 → ℤ, m ∈ S ↔ form (1 : Matrix (Fin 1) (Fin 1) ℚ)
          (fun i => t i - emb m i) = c) → Even S.card)
      ↔ ((∃ v : Fin 1 → ℤ, ∀ i, (2 : ℚ) * t i = (v i : ℚ)) ∧ ∀ k : Fin 1 → ℤ, t ≠ emb k) := by
  constructor
  · intro heven
    refine ⟨?_, multiplicity_even_imp_not_lattice standard_posDef heven⟩
    by_contra hno
    push_neg at hno
    have h2 : ∀ k : Fin 1 → ℤ, (fun i => (2 : ℚ) * t i) ≠ emb k := by
      intro k hk
      obtain ⟨i, hi⟩ := hno k
      exact hi (congrFun hk i)
    obtain ⟨c, S, hS, hodd⟩ := rank_one_multiplicity_odd_of_not_half h2
    exact hodd (heven c S hS)
  · rintro ⟨⟨v, hv⟩, hnl⟩ c S hS
    exact two_torsion_multiplicity_even _ hv hnl c S hS

end DiophantineLattice