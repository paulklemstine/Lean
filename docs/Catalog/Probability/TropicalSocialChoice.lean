/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical social choice: a min-plus Arrow theorem

We work in the tropical (min-plus) semiring `TR = Tropical (WithTop ℝ)` of *extended
costs*: tropical addition is `min` (the better of two costs), tropical multiplication is
ordinary addition of costs, the tropical `0` is `⊤` ("infinitely bad") and the tropical
`1` is the real number `0` ("neutral").

A *tropical social welfare function* on `n` voters is a map `f : TRⁿ → TR` subject to

* `IsTropLinear f` : `f x = ⨁ᵢ aᵢ ⊙ xᵢ` for some coefficient vector `a` (tropical
  linearity — this is the tropical analogue of *independence of irrelevant
  alternatives*: the aggregate is assembled coordinatewise, with no cross terms);
* `TropPareto f` : `f (c, …, c) = c` (unanimity / tropical Pareto);
* `TropScaleInv f` : `f (x ⊙ y) = f x ⊙ f y` (tropical multiplicativity: aggregating a
  sum of two cost profiles is the same as summing the two aggregates — the tropical
  analogue of *neutrality under a common change of scale*).

## Main results

* `tropical_arrow` : the three axioms force `f` to be the projection `x ↦ x k` for a
  unique voter `k` — a *tropical dictator*.
* `isTropLinear_of_tropIIA`, `tropical_arrow_of_tropIIA`, `tropical_arrow_tropIIA_iff` :
  linearity is in fact *derivable*, so the theorem holds with the weaker hypothesis
  `TropIIA` (preservation of tropical addition) in place of `IsTropLinear`.
* `tropForm_sandwich` : every unanimous tropical linear rule lies between the Rawlsian
  rule and the minimum rule of its oligarchy `{i | aᵢ = 1}`.
* `tropical_arrow_iff`, `tropicalSWF_eq_range_tropDictator` : the exact characterisation
  and the corresponding set equality; distinct voters give distinct dictators
  (`tropDictator_injective`).
* `exists_nondictatorial_of_tropPareto_tropIIA` : dropping only tropical
  multiplicativity, the "Rawlsian" rule `x ↦ ⨁ᵢ xᵢ` (the minimum cost, i.e. maximin) is
  tropically linear, satisfies tropical IIA and tropical Pareto, and is *not*
  dictatorial.  This confirms the conjecture that the weaker tropical axiom system
  admits non-dictatorial rules.
* `softMin_tendsto_inf'`, `trop_inf'_eq_tropCoalition` : the classical (zero
  temperature, Maslov dequantisation) limit.  The Boltzmann aggregator
  `-(1/t) log ∑ᵢ exp (-t yᵢ)` converges as `t → ∞` to the tropical coalition rule, and
  the tropical rule is literally the tropicalisation of that limit.
* `arrow_classical_dictatorship` : the *ordinal* rule induced by a tropical social
  welfare function ranks alternatives exactly as voter `k` does — Arrow's conclusion.
  The induced rule of a dictator satisfies classical Pareto and classical IIA
  (`dictator_classical_IIA`), while the non-dictatorial Rawlsian rule violates
  classical IIA (`rawlsian_violates_classical_IIA`), which is precisely why it escapes
  Arrow's theorem.
-/

namespace TropicalSocialChoice

open Finset Filter Tropical

/-- The tropical semiring of extended real costs: `⊕ = min`, `⊙ = +`,
tropical zero `= ⊤`, tropical one `= (0 : ℝ)`. -/
abbrev TR := Tropical (WithTop ℝ)

/-- A real number viewed as a (finite) tropical cost. -/
noncomputable def ofReal (r : ℝ) : TR := trop ((r : ℝ) : WithTop ℝ)

@[simp] theorem ofReal_le_ofReal {r s : ℝ} : ofReal r ≤ ofReal s ↔ r ≤ s := by
  simp [ofReal, ← untrop_le_iff]

theorem ofReal_injective : Function.Injective ofReal := by
  intro r s h
  have : (r : WithTop ℝ) = (s : WithTop ℝ) := by
    simpa [ofReal] using congrArg untrop h
  exact_mod_cast this

/-! ## The axioms -/

section Axioms

variable {n : ℕ}

/-- The tropical linear form with coefficient vector `a` : `x ↦ ⨁ᵢ aᵢ ⊙ xᵢ`, i.e.
`x ↦ minᵢ (aᵢ + xᵢ)`. -/
noncomputable def tropForm (a x : Fin n → TR) : TR := ∑ i, a i * x i

/-- `f` is a tropical linear map, i.e. a tropical `1 × n` matrix.  This is the tropical
form of independence of irrelevant alternatives: the social cost is assembled from the
individual costs coordinatewise, with no interaction terms. -/
def IsTropLinear (f : (Fin n → TR) → TR) : Prop := ∃ a : Fin n → TR, ∀ x, f x = tropForm a x

/-- Tropical Pareto (unanimity): if everybody assigns cost `c`, so does society. -/
def TropPareto (f : (Fin n → TR) → TR) : Prop := ∀ c : TR, f (fun _ => c) = c

/-- Tropical IIA: `f` preserves tropical addition, i.e. commutes with taking the
coordinatewise better of two profiles. -/
def TropIIA (f : (Fin n → TR) → TR) : Prop := ∀ x y, f (x + y) = f x + f y

/-- Tropical scale invariance: `f` preserves tropical multiplication, i.e. commutes with
adding two cost profiles. -/
def TropScaleInv (f : (Fin n → TR) → TR) : Prop := ∀ x y, f (x * y) = f x * f y

/-- The tropical dictator: society copies voter `k`. -/
def tropDictator (k : Fin n) : (Fin n → TR) → TR := fun x => x k

/-- `f` is dictatorial. -/
def IsTropDictatorial (f : (Fin n → TR) → TR) : Prop := ∃ k, f = tropDictator k

/-! ### Basic properties of tropical linear forms -/

theorem tropForm_apply_single (a : Fin n → TR) (j : Fin n) :
    tropForm a (Pi.single j 1) = a j := by
  classical
  rw [tropForm, Finset.sum_eq_single j]
  · simp
  · intro b _ hb
    have : (Pi.single j (1 : TR) : Fin n → TR) b = 0 := Pi.single_eq_of_ne hb 1
    rw [this, mul_zero]
  · intro h; simp at h

@[simp] theorem tropForm_zero (a : Fin n → TR) : tropForm a 0 = 0 := by
  simp [tropForm]

theorem tropForm_add (a x y : Fin n → TR) :
    tropForm a (x + y) = tropForm a x + tropForm a y := by
  simp only [tropForm, Pi.add_apply, mul_add]
  exact Finset.sum_add_distrib

theorem tropForm_const (a : Fin n → TR) (c : TR) :
    tropForm a (fun _ => c) = (∑ i, a i) * c := by
  rw [tropForm, Finset.sum_mul]

theorem tropForm_mono {a x y : Fin n → TR} (h : ∀ i, x i ≤ y i) :
    tropForm a x ≤ tropForm a y :=
  Finset.sum_le_sum fun i _ => mul_le_mul_right (h i) (a i)

/-- Tropical linearity implies tropical IIA. -/
theorem IsTropLinear.tropIIA {f : (Fin n → TR) → TR} (hf : IsTropLinear f) : TropIIA f := by
  obtain ⟨a, ha⟩ := hf
  intro x y
  rw [ha, ha, ha, tropForm_add]

/-- Tropical linearity implies monotonicity: lowering everybody's cost cannot raise the
social cost. -/
theorem IsTropLinear.mono {f : (Fin n → TR) → TR} (hf : IsTropLinear f) {x y : Fin n → TR}
    (h : ∀ i, x i ≤ y i) : f x ≤ f y := by
  obtain ⟨a, ha⟩ := hf
  rw [ha, ha]
  exact tropForm_mono h

/-- For a tropical linear form, unanimity is equivalent to the coefficients summing
tropically to `1`, i.e. `minᵢ aᵢ = 0`. -/
theorem tropPareto_tropForm_iff (a : Fin n → TR) :
    TropPareto (tropForm a) ↔ ∑ i, a i = 1 := by
  constructor
  · intro h
    have := h 1
    rwa [tropForm_const, mul_one] at this
  · intro h c
    rw [tropForm_const, h, one_mul]

/-- The tropical sum of the coefficients is at most every coefficient (`min ≤ each`);
under unanimity this says all coefficients are `≥ 1`, i.e. nonnegative shifts. -/
theorem one_le_coeff {a : Fin n → TR} (h : ∑ i, a i = 1) (j : Fin n) : 1 ≤ a j := by
  rw [← h, ← untrop_le_iff, Finset.untrop_sum']
  exact Finset.inf_le (Finset.mem_univ j)

/-- Under unanimity the minimum of the coefficients is attained: some voter has
coefficient exactly `1`.  Such voters form the *oligarchy*. -/
theorem exists_coeff_eq_one {a : Fin n → TR} (h : ∑ i, a i = 1) : ∃ k, a k = 1 := by
  have hne : (Finset.univ : Finset (Fin n)).Nonempty := by
    rcases (Finset.univ : Finset (Fin n)).eq_empty_or_nonempty with he | hn
    · rw [he, Finset.sum_empty] at h
      exact absurd h.symm one_ne_zero
    · exact hn
  obtain ⟨k, -, hk⟩ := Finset.exists_mem_eq_inf' hne (untrop ∘ a)
  refine ⟨k, ?_⟩
  have h1 : untrop (∑ i, a i) = untrop (a k) := by
    rw [Finset.untrop_sum', ← Finset.inf'_eq_inf hne, hk]; rfl
  rw [h] at h1
  exact untrop_injective h1.symm

/-! ### Tropical linearity is *derivable* from the other two axioms -/

theorem TropPareto.map_zero {f : (Fin n → TR) → TR} (hpar : TropPareto f) : f 0 = 0 := hpar 0

/-- Tropical IIA extends from pairs to arbitrary finite families. -/
theorem tropIIA_finset_sum {ι : Type*} {f : (Fin n → TR) → TR} (hiia : TropIIA f)
    (h0 : f 0 = 0) (s : Finset ι) (g : ι → (Fin n → TR)) :
    f (∑ i ∈ s, g i) = ∑ i ∈ s, f (g i) := by
  classical
  induction s using Finset.induction with
  | empty => simpa using h0
  | insert a s ha ih => rw [Finset.sum_insert ha, hiia, ih, Finset.sum_insert ha]

/-- Every profile is the tropical sum of its "scaled unit profiles". -/
theorem profile_decomposition (x : Fin n → TR) :
    x = ∑ i, ((fun _ => x i) * (Pi.single i 1) : Fin n → TR) := by
  classical
  funext j
  rw [Finset.sum_apply, Finset.sum_eq_single j]
  · simp
  · intro b _ hb
    show x b * (Pi.single b (1 : TR) : Fin n → TR) j = 0
    rw [Pi.single_eq_of_ne (Ne.symm hb) 1, mul_zero]
  · intro h; simp at h

/-- **Tropical linearity is not an extra assumption.**  Tropical IIA, unanimity and
tropical multiplicativity already force `f` to be a tropical linear form, with
coefficients `f (eᵢ)`. -/
theorem isTropLinear_of_tropIIA {f : (Fin n → TR) → TR} (hiia : TropIIA f)
    (hpar : TropPareto f) (hmul : TropScaleInv f) : IsTropLinear f := by
  refine ⟨fun i => f (Pi.single i 1), fun x => ?_⟩
  conv_lhs => rw [profile_decomposition x]
  rw [tropIIA_finset_sum hiia (TropPareto.map_zero hpar), tropForm]
  exact Finset.sum_congr rfl fun i _ => by rw [hmul, hpar (x i), mul_comm]

/-! ### The dictator satisfies every axiom -/

theorem tropForm_single (k : Fin n) : tropForm (Pi.single k 1) = tropDictator k := by
  classical
  funext x
  rw [tropForm, Finset.sum_eq_single k]
  · simp [tropDictator]
  · intro b _ hb
    have : (Pi.single k (1 : TR) : Fin n → TR) b = 0 := Pi.single_eq_of_ne hb 1
    rw [this, zero_mul]
  · intro h; simp at h

theorem tropDictator_isTropLinear (k : Fin n) : IsTropLinear (tropDictator k) :=
  ⟨Pi.single k 1, fun x => by rw [tropForm_single]⟩

theorem tropDictator_tropPareto (k : Fin n) : TropPareto (tropDictator k) := fun _ => rfl

theorem tropDictator_tropIIA (k : Fin n) : TropIIA (tropDictator k) := fun _ _ => rfl

theorem tropDictator_tropScaleInv (k : Fin n) : TropScaleInv (tropDictator k) := fun _ _ => rfl

/-- Distinct voters give distinct dictators. -/
theorem tropDictator_injective : Function.Injective (tropDictator (n := n)) := by
  classical
  intro j k h
  by_contra hjk
  have h1 : (Pi.single j (1 : TR) : Fin n → TR) j = (Pi.single j (1 : TR) : Fin n → TR) k :=
    congrFun h (Pi.single j 1)
  rw [Pi.single_eq_same, Pi.single_eq_of_ne (Ne.symm hjk)] at h1
  exact one_ne_zero h1

/-! ## The tropical Arrow theorem -/

/-- **Key step.**  Tropical multiplicativity forces the coefficients of a tropical linear
form to be pairwise "orthogonal": for `j ≠ k`, `a j ⊙ a k = 0`. -/
theorem coeff_mul_coeff_eq_zero {f : (Fin n → TR) → TR} {a : Fin n → TR}
    (ha : ∀ x, f x = tropForm a x) (hmul : TropScaleInv f) {j k : Fin n} (hjk : j ≠ k) :
    a j * a k = 0 := by
  classical
  have hprod : (Pi.single j (1 : TR) : Fin n → TR) * (Pi.single k (1 : TR) : Fin n → TR) = 0 := by
    funext i
    by_cases h : i = j
    · subst h
      show (Pi.single i (1 : TR) : Fin n → TR) i * (Pi.single k (1 : TR) : Fin n → TR) i = 0
      rw [Pi.single_eq_of_ne hjk, mul_zero]
    · show (Pi.single j (1 : TR) : Fin n → TR) i * (Pi.single k (1 : TR) : Fin n → TR) i = 0
      rw [Pi.single_eq_of_ne h, zero_mul]
  have := hmul (Pi.single j 1) (Pi.single k 1)
  rw [hprod, ha, ha, ha, tropForm_zero, tropForm_apply_single, tropForm_apply_single] at this
  exact this.symm

/-- **Tropical Arrow theorem.**  A tropical linear, unanimous, tropically multiplicative
social welfare function is a dictatorship, and the dictator is unique. -/
theorem tropical_arrow {f : (Fin n → TR) → TR} (hlin : IsTropLinear f) (hpar : TropPareto f)
    (hmul : TropScaleInv f) : ∃! k : Fin n, f = tropDictator k := by
  classical
  obtain ⟨a, ha⟩ := hlin
  -- some coefficient is nonzero, else `f` would be constantly `0`, contradicting unanimity
  have hex : ∃ k, a k ≠ 0 := by
    by_contra hno
    push_neg at hno
    have h1 : f (fun _ => 1) = 0 := by
      rw [ha, tropForm]
      exact Finset.sum_eq_zero fun i _ => by rw [hno i, zero_mul]
    rw [hpar 1] at h1
    exact one_ne_zero h1
  obtain ⟨k, hk⟩ := hex
  -- every other coefficient vanishes
  have hzero : ∀ j, j ≠ k → a j = 0 := by
    intro j hj
    rcases mul_eq_zero.mp (coeff_mul_coeff_eq_zero ha hmul hj) with h | h
    · exact h
    · exact absurd h hk
  -- hence `f x = a k ⊙ x k`
  have hfx : ∀ x, f x = a k * x k := by
    intro x
    rw [ha, tropForm, Finset.sum_eq_single k]
    · intro b _ hb; rw [hzero b hb, zero_mul]
    · intro h; simp at h
  -- unanimity pins down `a k = 1`
  have hak : a k = 1 := by
    have := hpar 1
    rw [hfx] at this
    simpa using this
  refine ⟨k, ?_, ?_⟩
  · funext x
    rw [hfx, hak, one_mul]
    rfl
  · intro j hj
    apply tropDictator_injective
    rw [← hj]
    funext x
    rw [hfx, hak, one_mul]
    rfl

/-- The tropical social welfare functions are *exactly* the dictators. -/
theorem tropical_arrow_iff (f : (Fin n → TR) → TR) :
    (IsTropLinear f ∧ TropPareto f ∧ TropScaleInv f) ↔ IsTropDictatorial f := by
  constructor
  · rintro ⟨hlin, hpar, hmul⟩
    obtain ⟨k, hk, -⟩ := tropical_arrow hlin hpar hmul
    exact ⟨k, hk⟩
  · rintro ⟨k, rfl⟩
    exact ⟨tropDictator_isTropLinear k, tropDictator_tropPareto k, tropDictator_tropScaleInv k⟩

/-- **Tropical Arrow theorem, strong form.**  Linearity need not be assumed: tropical
IIA, unanimity and tropical multiplicativity alone force a unique dictator. -/
theorem tropical_arrow_of_tropIIA {f : (Fin n → TR) → TR} (hiia : TropIIA f)
    (hpar : TropPareto f) (hmul : TropScaleInv f) : ∃! k : Fin n, f = tropDictator k :=
  tropical_arrow (isTropLinear_of_tropIIA hiia hpar hmul) hpar hmul

/-- The tropical social welfare functions, axiomatised by tropical IIA + tropical Pareto
+ tropical scale invariance, are exactly the dictators. -/
theorem tropical_arrow_tropIIA_iff (f : (Fin n → TR) → TR) :
    (TropIIA f ∧ TropPareto f ∧ TropScaleInv f) ↔ IsTropDictatorial f := by
  constructor
  · rintro ⟨hiia, hpar, hmul⟩
    obtain ⟨k, hk, -⟩ := tropical_arrow_of_tropIIA hiia hpar hmul
    exact ⟨k, hk⟩
  · rintro ⟨k, rfl⟩
    exact ⟨tropDictator_tropIIA k, tropDictator_tropPareto k, tropDictator_tropScaleInv k⟩

/-- Set-level form of the tropical Arrow theorem. -/
theorem tropicalSWF_eq_range_tropDictator :
    {f : (Fin n → TR) → TR | IsTropLinear f ∧ TropPareto f ∧ TropScaleInv f} =
      Set.range (tropDictator (n := n)) := by
  ext f
  simpa [IsTropDictatorial, eq_comm] using tropical_arrow_iff f

end Axioms

/-! ## Escaping the theorem: coalition (Rawlsian) rules -/

section Coalition

variable {n : ℕ}

/-- The coalition rule of a set `s` of voters: the social cost is the tropical sum
(= minimum) of the costs of the members of `s`.  For `s = univ` this is the Rawlsian
maximin rule. -/
noncomputable def tropCoalition (s : Finset (Fin n)) : (Fin n → TR) → TR := fun x => ∑ i ∈ s, x i

/-- The coalition rule is a tropical linear form, with `0/1` coefficients. -/
theorem tropCoalition_isTropLinear (s : Finset (Fin n)) : IsTropLinear (tropCoalition s) := by
  classical
  refine ⟨fun i => if i ∈ s then 1 else 0, fun x => ?_⟩
  rw [tropForm, tropCoalition]
  rw [← Finset.sum_filter_add_sum_filter_not Finset.univ (· ∈ s)]
  have h1 : ∑ i ∈ Finset.univ.filter (fun i => i ∈ s), (if i ∈ s then (1 : TR) else 0) * x i
      = ∑ i ∈ s, x i := by
    rw [Finset.filter_mem_eq_inter, Finset.univ_inter]
    exact Finset.sum_congr rfl fun i hi => by rw [if_pos hi, one_mul]
  have h2 : ∑ i ∈ Finset.univ.filter (fun i => ¬ i ∈ s), (if i ∈ s then (1 : TR) else 0) * x i
      = 0 :=
    Finset.sum_eq_zero fun i hi => by
      rw [if_neg (Finset.mem_filter.mp hi).2, zero_mul]
  rw [h1, h2, add_zero]

theorem tropCoalition_tropIIA (s : Finset (Fin n)) : TropIIA (tropCoalition s) :=
  (tropCoalition_isTropLinear s).tropIIA

/-- A nonempty coalition rule is unanimous: tropical addition is idempotent. -/
theorem tropCoalition_tropPareto {s : Finset (Fin n)} (hs : s.Nonempty) :
    TropPareto (tropCoalition s) := by
  intro c
  have : tropCoalition s (fun _ => c) = s.card • c := by
    simp [tropCoalition]
  rw [this]
  have hpos : 0 < s.card := Finset.card_pos.mpr hs
  obtain ⟨m, hm⟩ : ∃ m, s.card = m + 1 := ⟨s.card - 1, by omega⟩
  rw [hm, Tropical.succ_nsmul]

/-- A coalition containing two distinct voters is not a dictatorship. -/
theorem tropCoalition_not_dictatorial {s : Finset (Fin n)} {j k : Fin n} (hj : j ∈ s)
    (hk : k ∈ s) (hjk : j ≠ k) : ¬ IsTropDictatorial (tropCoalition s) := by
  classical
  rintro ⟨m, hm⟩
  -- pick a member of the coalition different from the alleged dictator
  obtain ⟨p, hp, hpm⟩ : ∃ p ∈ s, p ≠ m := by
    by_cases h : j = m
    · exact ⟨k, hk, by rw [← h]; exact fun hc => hjk hc.symm⟩
    · exact ⟨j, hj, h⟩
  have h1 : tropCoalition s (Pi.single p 1) = 1 := by
    rw [tropCoalition, Finset.sum_eq_single p]
    · simp
    · intro b _ hb
      exact Pi.single_eq_of_ne hb 1
    · intro h; exact absurd hp h
  have h2 : tropDictator m (Pi.single p (1 : TR)) = 0 :=
    Pi.single_eq_of_ne (Ne.symm hpm) 1
  rw [hm, h2] at h1
  exact one_ne_zero h1.symm

/-- A coalition containing two distinct voters violates tropical multiplicativity. -/
theorem tropCoalition_not_tropScaleInv {s : Finset (Fin n)} {j k : Fin n} (hj : j ∈ s)
    (hk : k ∈ s) (hjk : j ≠ k) : ¬ TropScaleInv (tropCoalition s) := by
  classical
  intro hmul
  have hprod : (Pi.single j (1 : TR) : Fin n → TR) * (Pi.single k (1 : TR) : Fin n → TR) = 0 := by
    funext i
    by_cases h : i = j
    · subst h
      show (Pi.single i (1 : TR) : Fin n → TR) i * (Pi.single k (1 : TR) : Fin n → TR) i = 0
      rw [Pi.single_eq_of_ne hjk, mul_zero]
    · show (Pi.single j (1 : TR) : Fin n → TR) i * (Pi.single k (1 : TR) : Fin n → TR) i = 0
      rw [Pi.single_eq_of_ne h, zero_mul]
  have hone : ∀ p ∈ s, tropCoalition s (Pi.single p 1) = 1 := by
    intro p hp
    rw [tropCoalition, Finset.sum_eq_single p]
    · simp
    · intro b _ hb
      exact Pi.single_eq_of_ne hb 1
    · intro h; exact absurd hp h
  have := hmul (Pi.single j 1) (Pi.single k 1)
  rw [hprod, hone j hj, hone k hk, mul_one] at this
  have hzero : tropCoalition s (0 : Fin n → TR) = 0 := by
    simp [tropCoalition]
  rw [hzero] at this
  exact one_ne_zero this.symm

/-- **The conjecture, confirmed.**  With at least two voters, the weaker axiom system
(tropical IIA together with tropical Pareto) admits non-dictatorial social welfare
functions: the Rawlsian rule `x ↦ ⨁ᵢ xᵢ = minᵢ xᵢ`. -/
theorem exists_nondictatorial_of_tropPareto_tropIIA (hn : 2 ≤ n) :
    ∃ f : (Fin n → TR) → TR,
      IsTropLinear f ∧ TropIIA f ∧ TropPareto f ∧ ¬ IsTropDictatorial f := by
  have h0 : (0 : ℕ) < n := by omega
  have h1 : (1 : ℕ) < n := by omega
  refine ⟨tropCoalition Finset.univ, tropCoalition_isTropLinear _,
    tropCoalition_tropIIA _, tropCoalition_tropPareto ⟨⟨0, h0⟩, Finset.mem_univ _⟩, ?_⟩
  refine tropCoalition_not_dictatorial (j := ⟨0, h0⟩) (k := ⟨1, h1⟩) (Finset.mem_univ _)
    (Finset.mem_univ _) ?_
  simp [Fin.ext_iff]

/-- The oligarchy of a coefficient vector: the voters whose coefficient is `1`, i.e. who
enter the aggregate with no handicap. -/
noncomputable def tropSupport (a : Fin n → TR) : Finset (Fin n) :=
  Finset.univ.filter (fun i => a i = 1)

theorem tropSupport_nonempty {a : Fin n → TR} (h : ∑ i, a i = 1) :
    (tropSupport a).Nonempty := by
  classical
  obtain ⟨k, hk⟩ := exists_coeff_eq_one h
  exact ⟨k, Finset.mem_filter.mpr ⟨Finset.mem_univ k, hk⟩⟩

theorem tropAdd_le_right (x y : TR) : x + y ≤ y := by
  rw [← untrop_le_iff, untrop_add]
  exact min_le_right _ _

/-- Every unanimous tropical linear rule is at least as generous as its oligarchy rule. -/
theorem tropForm_le_tropCoalition_tropSupport (a x : Fin n → TR) :
    tropForm a x ≤ tropCoalition (tropSupport a) x := by
  classical
  have h1 : ∑ i ∈ tropSupport a, a i * x i = tropCoalition (tropSupport a) x :=
    Finset.sum_congr rfl fun i hi => by rw [(Finset.mem_filter.mp hi).2, one_mul]
  rw [tropForm, ← Finset.sum_sdiff (Finset.subset_univ (tropSupport a)), h1]
  exact tropAdd_le_right _ _

/-- No unanimous tropical linear rule is more generous than the Rawlsian rule. -/
theorem tropCoalition_univ_le_tropForm {a : Fin n → TR} (h : ∑ i, a i = 1) (x : Fin n → TR) :
    tropCoalition Finset.univ x ≤ tropForm a x := by
  rw [tropCoalition, tropForm]
  refine Finset.sum_le_sum fun i _ => ?_
  simpa [mul_comm] using mul_le_mul_right (one_le_coeff h i) (x i)

/-- **Sandwich theorem.**  Every unanimous tropical linear social welfare function lies
between the Rawlsian (all-voter minimum) rule and the minimum rule of its oligarchy. -/
theorem tropForm_sandwich {a : Fin n → TR} (h : ∑ i, a i = 1) (x : Fin n → TR) :
    tropCoalition Finset.univ x ≤ tropForm a x ∧
      tropForm a x ≤ tropCoalition (tropSupport a) x :=
  ⟨tropCoalition_univ_le_tropForm h x, tropForm_le_tropCoalition_tropSupport a x⟩

/-- The Rawlsian rule of a two-element coalition is the pointwise tropical sum, i.e. the
minimum of the two costs. -/
theorem tropCoalition_pair {j k : Fin n} (hjk : j ≠ k) (x : Fin n → TR) :
    tropCoalition {j, k} x = x j + x k := by
  classical
  rw [tropCoalition, Finset.sum_pair hjk]

end Coalition

/-! ## The classical limit: Maslov dequantisation -/

section ClassicalLimit

variable {ι : Type*}

/-- The Boltzmann ("finite temperature") aggregator at inverse temperature `t`:
`-(1/t) · log ∑ᵢ exp (-t yᵢ)`.  It is a smooth, strictly Paretian aggregator of real
costs. -/
noncomputable def softMin (s : Finset ι) (t : ℝ) (y : ι → ℝ) : ℝ :=
  -(1 / t) * Real.log (∑ i ∈ s, Real.exp (-(t * y i)))

/-- For a single voter, the Boltzmann aggregator *is* the dictator, at every
temperature. -/
theorem softMin_singleton (k : ι) (y : ι → ℝ) {t : ℝ} (ht : t ≠ 0) :
    softMin {k} t y = y k := by
  rw [softMin, Finset.sum_singleton, Real.log_exp]
  field_simp

/-- Quantitative Maslov dequantisation: the Boltzmann aggregator is squeezed between the
tropical (minimum) aggregator and that value shifted by `log |s| / t`. -/
theorem softMin_bounds (s : Finset ι) (hs : s.Nonempty) (y : ι → ℝ) {t : ℝ} (ht : 0 < t) :
    s.inf' hs y - Real.log s.card / t ≤ softMin s t y ∧ softMin s t y ≤ s.inf' hs y := by
  set m := s.inf' hs y with hm
  obtain ⟨i₀, hi₀s, hi₀⟩ := Finset.exists_mem_eq_inf' hs y
  have hpos : 0 < ∑ i ∈ s, Real.exp (-(t * y i)) :=
    Finset.sum_pos (fun i _ => Real.exp_pos _) hs
  have hlb : Real.exp (-(t * m)) ≤ ∑ i ∈ s, Real.exp (-(t * y i)) := by
    refine (Finset.single_le_sum (f := fun i => Real.exp (-(t * y i)))
      (fun i _ => (Real.exp_pos _).le) hi₀s).trans_eq' ?_
    rw [hm, hi₀]
  have hub : ∑ i ∈ s, Real.exp (-(t * y i)) ≤ s.card * Real.exp (-(t * m)) := by
    calc ∑ i ∈ s, Real.exp (-(t * y i)) ≤ ∑ _i ∈ s, Real.exp (-(t * m)) :=
          Finset.sum_le_sum fun i hi =>
            Real.exp_le_exp.mpr (by nlinarith [Finset.inf'_le (f := y) hi])
      _ = s.card * Real.exp (-(t * m)) := by simp [Finset.sum_const, nsmul_eq_mul]
  have hlog1 : -(t * m) ≤ Real.log (∑ i ∈ s, Real.exp (-(t * y i))) := by
    simpa using Real.log_le_log (Real.exp_pos _) hlb
  have hcard : (0 : ℝ) < s.card := by exact_mod_cast Finset.card_pos.mpr hs
  have hlog2 : Real.log (∑ i ∈ s, Real.exp (-(t * y i))) ≤ Real.log s.card + -(t * m) := by
    have := Real.log_le_log hpos hub
    rwa [Real.log_mul (ne_of_gt hcard) (Real.exp_ne_zero _), Real.log_exp] at this
  have hinv : (0 : ℝ) ≤ 1 / t := by positivity
  constructor
  · have h2 := mul_le_mul_of_nonneg_left hlog2 hinv
    have e2 : (1 / t) * (Real.log s.card + -(t * m)) = Real.log s.card / t - m := by
      field_simp; ring
    rw [e2] at h2
    simp only [softMin]
    linarith
  · have h1 := mul_le_mul_of_nonneg_left hlog1 hinv
    have e1 : (1 / t) * (-(t * m)) = -m := by field_simp
    rw [e1] at h1
    simp only [softMin]
    linarith

/-- **Zero-temperature limit.**  As `t → ∞` the Boltzmann aggregator converges to the
tropical (minimum) aggregator of the coalition `s`. -/
theorem softMin_tendsto_inf' (s : Finset ι) (hs : s.Nonempty) (y : ι → ℝ) :
    Tendsto (fun t => softMin s t y) atTop (nhds (s.inf' hs y)) := by
  set m := s.inf' hs y
  have hlow : Tendsto (fun t : ℝ => m - Real.log s.card / t) atTop (nhds m) := by
    have h0 : Tendsto (fun t : ℝ => Real.log s.card / t) atTop (nhds 0) :=
      Filter.Tendsto.div_atTop tendsto_const_nhds Filter.tendsto_id
    simpa using (tendsto_const_nhds (x := m) (f := (atTop : Filter ℝ))).sub h0
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow tendsto_const_nhds ?_ ?_
  · filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht
    exact (softMin_bounds s hs y ht).1
  · filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht
    exact (softMin_bounds s hs y ht).2

/-- The tropicalisation of the zero-temperature limit is exactly the tropical coalition
rule: tropical social choice *is* the classical limit of Boltzmann aggregation. -/
theorem trop_inf'_eq_tropCoalition {n : ℕ} (s : Finset (Fin n)) (hs : s.Nonempty)
    (y : Fin n → ℝ) :
    ofReal (s.inf' hs y) = tropCoalition s (fun i => ofReal (y i)) := by
  have hcoe : ((s.inf' hs y : ℝ) : WithTop ℝ) = s.inf (fun i => ((y i : ℝ) : WithTop ℝ)) := by
    rw [← Finset.inf'_eq_inf hs]
    exact Finset.comp_inf'_eq_inf'_comp hs (fun r : ℝ => (r : WithTop ℝ)) (by intro x y; simp)
  rw [ofReal, hcoe, Finset.trop_inf, tropCoalition]
  rfl

end ClassicalLimit

/-! ## Reduction to classical (ordinal) social choice -/

section Classical

variable {n : ℕ} {α : Type*}

/-- The social cost that a tropical rule `f` assigns to alternative `a`, given a profile
`u` of individual cost functions (lower cost = more preferred). -/
noncomputable def socialCost (f : (Fin n → TR) → TR) (u : Fin n → α → ℝ) (a : α) : TR :=
  f (fun i => ofReal (u i a))

/-- The induced ordinal social preference: society weakly prefers `a` to `b`. -/
def SocPrefers (f : (Fin n → TR) → TR) (u : Fin n → α → ℝ) (a b : α) : Prop :=
  socialCost f u a ≤ socialCost f u b

theorem socialCost_tropDictator (k : Fin n) (u : Fin n → α → ℝ) (a : α) :
    socialCost (tropDictator k) u a = ofReal (u k a) := rfl

/-- **Arrow's conclusion in the classical limit.**  The ordinal rule induced by a
tropical social welfare function is the dictatorship of a single voter `k`. -/
theorem arrow_classical_dictatorship {f : (Fin n → TR) → TR} (hlin : IsTropLinear f)
    (hpar : TropPareto f) (hmul : TropScaleInv f) :
    ∃ k : Fin n, ∀ (u : Fin n → α → ℝ) (a b : α), SocPrefers f u a b ↔ u k a ≤ u k b := by
  obtain ⟨k, hk, -⟩ := tropical_arrow hlin hpar hmul
  refine ⟨k, fun u a b => ?_⟩
  rw [SocPrefers, hk, socialCost_tropDictator, socialCost_tropDictator, ofReal_le_ofReal]

/-- Classical Pareto: any tropical linear rule respects unanimous weak preference. -/
theorem classical_pareto {f : (Fin n → TR) → TR} (hlin : IsTropLinear f) (u : Fin n → α → ℝ)
    (a b : α) (h : ∀ i, u i a ≤ u i b) : SocPrefers f u a b :=
  hlin.mono fun i => ofReal_le_ofReal.mpr (h i)

/-- Classical independence of irrelevant alternatives, for a dictator: the social
comparison of `a` and `b` depends only on the individual comparisons of `a` and `b`. -/
theorem dictator_classical_IIA (k : Fin n) (u v : Fin n → α → ℝ) (a b : α)
    (h : ∀ i, (u i a ≤ u i b ↔ v i a ≤ v i b)) :
    SocPrefers (tropDictator k) u a b ↔ SocPrefers (tropDictator k) v a b := by
  rw [SocPrefers, SocPrefers, socialCost_tropDictator, socialCost_tropDictator,
    socialCost_tropDictator, socialCost_tropDictator, ofReal_le_ofReal, ofReal_le_ofReal]
  exact h k

/-- The Rawlsian (two-voter minimum) rule violates classical independence of irrelevant
alternatives: two profiles inducing the same individual rankings of `a` and `b` can be
ranked oppositely by society.  This is exactly why the non-dictatorial tropical rules do
not contradict Arrow's theorem: they use cardinal, not merely ordinal, information. -/
theorem rawlsian_violates_classical_IIA :
    ∃ (u v : Fin 2 → Bool → ℝ),
      (∀ i, (u i true ≤ u i false ↔ v i true ≤ v i false)) ∧
      SocPrefers (tropCoalition Finset.univ) u true false ∧
      ¬ SocPrefers (tropCoalition Finset.univ) v true false := by
  classical
  refine ⟨![fun x => if x then (2 : ℝ) else 3, fun x => if x then (5 : ℝ) else 4],
    ![fun x => if x then (2 : ℝ) else 3, fun x => if x then (5 : ℝ) else 1], ?_, ?_, ?_⟩
  · intro i
    fin_cases i <;> norm_num
  · rw [SocPrefers, socialCost, socialCost, tropCoalition, tropCoalition, ← untrop_le_iff]
    simp only [Fin.sum_univ_two, untrop_add, ofReal, untrop_trop, Matrix.cons_val_zero,
      Matrix.cons_val_one, if_pos, Bool.false_eq_true]
    rw [← WithTop.coe_min, ← WithTop.coe_min, WithTop.coe_le_coe]
    norm_num
  · rw [SocPrefers, socialCost, socialCost, tropCoalition, tropCoalition, ← untrop_le_iff]
    simp only [Fin.sum_univ_two, untrop_add, ofReal, untrop_trop, Matrix.cons_val_zero,
      Matrix.cons_val_one, if_pos, Bool.false_eq_true]
    rw [← WithTop.coe_min, ← WithTop.coe_min, WithTop.coe_le_coe]
    norm_num

end Classical

end TropicalSocialChoice