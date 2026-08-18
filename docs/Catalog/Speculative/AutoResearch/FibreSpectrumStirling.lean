import Logic.FibreSpectrumRank

/-!
# Spectral inversion, and the classical falling-factorial identity as a degenerate orbit count

`Catalog/Logic/FibreSpectrumRank.lean` proved the **rank collapse** `m_P = t_{rank P}` of the
fibre spectrum of the orbit–pattern map and the resulting Stirling expansion

  `#(X^k/G) = Σ_{r ≤ k} S(k,r) · t_r`,   `t_r = ` number of orbits of injective `r`-tuples.

This file draws two consequences.

* **Inversion.**  Since `S(k,k) = 1` (`stirling_self`) the expansion is *triangular*, so the
  spectrum is recovered from the orbit counts by the recursion
  `#(X^k/G) = Σ_{r < k} S(k,r)·t_r + t_k` (`card_orbits_eq_sum_range_add_injOrbits`).  Hence the
  sequence `k ↦ #(X^k/G)` and the spectrum `r ↦ t_r` determine each other; combined with
  `injOrbits_eq_zero_of_lt` the sum is really finite of length `min k |X| + 1`.

* **Degeneration.**  For the *trivial* action the orbit quotient is the tuple type itself and
  `t_r` is the number of injective `r`-tuples, i.e. the falling factorial.  The Stirling expansion
  then degenerates to the classical identity

    `n^k = Σ_{r ≤ k} S(k,r) · n^{\underline r}`   (`pow_eq_sum_stirling_descFactorial`),

  the change of basis between ordinary powers and falling factorials — obtained here purely from
  the orbit-counting machinery, with the Stirling numbers *defined* as counts of kernel patterns.
  This also certifies that `stirling` really is the Stirling triangle of the second kind.

No `sorry`s, no `native_decide`, no new axioms.
-/

open Finset MulAction Function

namespace FibreSpectrum

open MoonshineBell MoonshineFibre

/-! ## Part 1: triangularity and inversion of the Stirling expansion -/

section Inversion

variable {k : ℕ}

/-- A pattern has full rank exactly when it is the discrete pattern. -/
theorem rank_eq_iff_eq_idPattern (P : Pattern k) : rank P = k ↔ P = idPattern k := by
  classical
  refine ⟨fun h => ?_, fun h => by rw [h]; exact rank_idPattern k⟩
  have huniv : leaders P = (Finset.univ : Finset (Fin k)) := by
    refine Finset.eq_univ_of_card _ ?_
    rw [card_leaders, h]
    simp
  refine Subtype.ext (funext fun i => ?_)
  exact leader_fixed (huniv ▸ Finset.mem_univ i)

/-- **Triangularity.**  The top Stirling coefficient is `1`: only the discrete pattern has full
rank. -/
theorem stirling_self (k : ℕ) : stirling k k = 1 := by
  classical
  have h : (Finset.univ.filter fun P : Pattern k => rank P = k) = {idPattern k} := by
    ext P
    simp [rank_eq_iff_eq_idPattern]
  rw [stirling, h, Finset.card_singleton]

variable (G : Type*) [Group G] (X : Type*) [MulAction G X] [Finite X]

/-- Beyond `|X|` the spectrum vanishes: there are no injective `r`-tuples at all. -/
theorem injOrbits_eq_zero_of_lt {r : ℕ} (h : Nat.card X < r) : injOrbits G X r = 0 := by
  have hempty : IsEmpty {o : orbitRel.Quotient G (Fin r → X) // orbitPattern o = idPattern r} := by
    constructor
    rintro ⟨o, ho⟩
    induction o using Quotient.inductionOn with
    | h f =>
      have hf : Injective f := injective_iff_kerPat_eq_id.2 (congrArg Subtype.val ho)
      have hle : Nat.card (Fin r) ≤ Nat.card X := Nat.card_le_card_of_injective f hf
      simp only [Nat.card_eq_fintype_card, Fintype.card_fin] at hle
      omega
  haveI := hempty
  rw [injOrbits, patternMultiplicity]
  exact Nat.card_of_isEmpty

/-- **Spectral inversion.**  The Stirling expansion is triangular, so the spectrum is determined
recursively by the orbit counts: `t_k = #(X^k/G) − Σ_{r<k} S(k,r)·t_r`. -/
theorem card_orbits_eq_sum_range_add_injOrbits (k : ℕ) :
    Nat.card (orbitRel.Quotient G (Fin k → X))
      = (∑ r ∈ Finset.range k, stirling k r * injOrbits G X r) + injOrbits G X k := by
  rw [card_orbits_eq_sum_stirling k G X, Finset.sum_range_succ, stirling_self, one_mul]

end Inversion

/-! ## Part 2: the trivial action and the falling-factorial identity -/

/-- The number of injective `r`-tuples in a finite type is the falling factorial. -/
theorem card_injective_tuples (X : Type*) [Finite X] (r : ℕ) :
    Nat.card {f : Fin r → X // Injective f} = (Nat.card X).descFactorial r := by
  classical
  letI := Fintype.ofFinite X
  rw [Nat.card_congr (Equiv.subtypeInjectiveEquivEmbedding (Fin r) X),
    Nat.card_eq_fintype_card, Fintype.card_embedding_eq, Nat.card_eq_fintype_card,
    Fintype.card_fin]

section Trivial

variable {G : Type*} [Group G] {X : Type*} [MulAction G X]

/-- For a trivial action, orbits are points: the orbit quotient of `n`-tuples is the tuple type
itself. -/
noncomputable def trivialQuotientEquiv (htriv : ∀ (g : G) (x : X), g • x = x) (n : ℕ) :
    (Fin n → X) ≃ orbitRel.Quotient G (Fin n → X) :=
  Equiv.ofBijective (Quotient.mk (orbitRel G (Fin n → X)))
    ⟨by
      intro a b hab
      obtain ⟨g, hg⟩ := (orbitRel_apply).1 (Quotient.exact hab)
      have hgb : g • b = b := funext fun i => htriv g (b i)
      have hab' : a = g • b := hg.symm
      rw [hab', hgb], Quotient.mk_surjective⟩

theorem card_quotient_of_trivial (htriv : ∀ (g : G) (x : X), g • x = x) [Finite X] (n : ℕ) :
    Nat.card (orbitRel.Quotient G (Fin n → X)) = Nat.card X ^ n := by
  classical
  letI := Fintype.ofFinite X
  rw [← Nat.card_congr (trivialQuotientEquiv htriv n)]
  simp [Nat.card_eq_fintype_card]

/-- For a trivial action, the `r`-th spectral value is the number of injective `r`-tuples, i.e.
the falling factorial `|X|^{\underline r}`. -/
theorem injOrbits_of_trivial (htriv : ∀ (g : G) (x : X), g • x = x) [Finite X] (r : ℕ) :
    injOrbits G X r = (Nat.card X).descFactorial r := by
  classical
  letI := Fintype.ofFinite X
  have hsub : {f : Fin r → X // Injective f} ≃
      {o : orbitRel.Quotient G (Fin r → X) // orbitPattern o = idPattern r} :=
    (trivialQuotientEquiv htriv r).subtypeEquiv fun f => by
      constructor
      · intro hf
        exact Subtype.ext (kerPat_of_injective hf)
      · intro ho
        exact injective_iff_kerPat_eq_id.2 (congrArg Subtype.val ho)
  have h1 : injOrbits G X r = Nat.card {f : Fin r → X // Injective f} := by
    rw [injOrbits, patternMultiplicity, Nat.card_congr hsub]
  rw [h1, card_injective_tuples X r]

end Trivial

/-! ## Part 3: the classical change of basis between powers and falling factorials -/

/-- **Powers expand in falling factorials with Stirling coefficients.**
`n^k = Σ_{r ≤ k} S(k,r)·n^{\underline r}`.

The proof is a degeneration of the orbit-counting theorem `card_orbits_eq_sum_stirling`: apply it
to the trivial group `⊥ ≤ Sym(Fin n)` acting on `Fin n`, where the orbit count of `k`-tuples is
`n^k` and the spectrum is the falling factorial. -/
theorem pow_eq_sum_stirling_descFactorial (n k : ℕ) :
    n ^ k = ∑ r ∈ Finset.range (k + 1), stirling k r * n.descFactorial r := by
  classical
  set G := (⊥ : Subgroup (Equiv.Perm (Fin n))) with hG
  have htriv : ∀ (g : G) (x : Fin n), g • x = x := by
    intro g x
    have : (g : Equiv.Perm (Fin n)) = 1 := Subgroup.mem_bot.1 g.2
    show (g : Equiv.Perm (Fin n)) • x = x
    rw [this, one_smul]
  have hcardX : Nat.card (Fin n) = n := by simp
  have hmain := card_orbits_eq_sum_stirling k G (Fin n)
  rw [card_quotient_of_trivial htriv k, hcardX] at hmain
  rw [hmain]
  exact Finset.sum_congr rfl fun r _ => by
    rw [injOrbits_of_trivial htriv r, hcardX]

-- Numerical corollaries of the identity (checked against OEIS A008277 rows).
example : (4 : ℕ) ^ 3 = ∑ r ∈ Finset.range 4, stirling 3 r * Nat.descFactorial 4 r :=
  pow_eq_sum_stirling_descFactorial 4 3

example : (5 : ℕ) ^ 4 = ∑ r ∈ Finset.range 5, stirling 4 r * Nat.descFactorial 5 r :=
  pow_eq_sum_stirling_descFactorial 5 4

/-! ## Part 4: spectrum and orbit-count sequence determine each other -/

section Rigidity

variable (G : Type*) [Group G] (X : Type*) [MulAction G X] [Finite X]
  (H : Type*) [Group H] (Y : Type*) [MulAction H Y] [Finite Y]

/-- **Rigidity, one direction.**  Two actions with the same orbit counts on tuples of every
length have the same injective-orbit spectrum.  This is triangular inversion of the Stirling
expansion, run as a strong induction. -/
theorem injOrbits_eq_of_card_orbits_eq
    (h : ∀ k, Nat.card (orbitRel.Quotient G (Fin k → X))
      = Nat.card (orbitRel.Quotient H (Fin k → Y))) (r : ℕ) :
    injOrbits G X r = injOrbits H Y r := by
  induction r using Nat.strong_induction_on with
  | _ k ih =>
    have h1 := card_orbits_eq_sum_range_add_injOrbits G X k
    have h2 := card_orbits_eq_sum_range_add_injOrbits H Y k
    have hk := h k
    have hs : (∑ r ∈ Finset.range k, stirling k r * injOrbits G X r)
        = ∑ r ∈ Finset.range k, stirling k r * injOrbits H Y r :=
      Finset.sum_congr rfl fun r hr => by rw [ih r (Finset.mem_range.1 hr)]
    omega

/-- **Rigidity, converse direction.**  Equal spectra give equal orbit counts. -/
theorem card_orbits_eq_of_injOrbits_eq
    (h : ∀ r, injOrbits G X r = injOrbits H Y r) (k : ℕ) :
    Nat.card (orbitRel.Quotient G (Fin k → X)) = Nat.card (orbitRel.Quotient H (Fin k → Y)) := by
  rw [card_orbits_eq_sum_stirling k G X, card_orbits_eq_sum_stirling k H Y]
  exact Finset.sum_congr rfl fun r _ => by rw [h r]

end Rigidity

end FibreSpectrum