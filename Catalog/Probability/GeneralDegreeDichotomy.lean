/-
# The multiplicative dichotomy in arbitrary degree (Factoring Lab, Phase A v19c — cycle 3)

This file closes **Conjecture B** of `FUTURE_DIRECTIONS.md`: the multiplicative
dichotomy, proved for the affine family in
`Catalog/Probability/MultiplicativeDichotomy.lean` and for the quadratic family
in `Catalog/Probability/QuadraticDichotomy.lean`, holds for **every** polynomial
invariant, in every degree, with the reduction data tracked *generically* — as
polynomials in the symmetric coordinates `(s, N)` rather than in the (unknown)
factors `p`, `q`.

`Catalog/Probability/SymmetricReduction.lean` proved the identity
`F(p)F(q) = A² + A B s + B² N` with `A`, `B` obtained by reducing `F` modulo
`(X − p)(X − q)`; there `A` and `B` were computed *from the factors*, so the
identity was not yet usable by an algorithm that only sees `N`.  Here the
reduction is carried out once and for all over the ring

`ℤ[N][s] = Polynomial (Polynomial ℤ)`  (`FactoringLab.SN`),

by the explicit recursion `X^{k+1} ≡ (B_k s + A_k) X − N B_k` coming from
`X² ≡ sX − N`.  The resulting universal polynomial

`Ψ_F(s, N) = A_F² + A_F B_F s + B_F² N`   (`FactoringLab.symPoly`)

satisfies `Ψ_F(p+q, pq) = F(p)F(q)` for **all** integers `p, q`
(`FactoringLab.symPoly_eval`), and has `s`-degree at most `2 deg F`
(`FactoringLab.degree_symPoly_le`).

The dichotomy (`FactoringLab.general_degree_dichotomy`) is then exact and
algorithmic.  Fix `N` and let `ψ = Ψ_F(·, N) ∈ ℤ[s]`.  Either

* `ψ` is constant, and then the invariant `F(p)F(q)` takes the *same value*
  `ψ(0)` for every factorization `N = pq` — it is `N`-only in the strongest
  possible sense, carrying literally no information about the factors; or
* `ψ` is nonconstant, and then `s = p + q` is a root of the nonzero polynomial
  `ψ − T` (`T` the observed invariant value), of degree at most `2 deg F`, so
  there are at most `2 deg F` candidate sums, and each candidate yields the
  factorization in closed form through `FactoringLab.recovery_from_sum`
  (`FactoringLab.general_degree_recovery`).

Both branches are realized: `F = X` falls on the `N`-only side
(`FactoringLab.symSpec_X`), and `F = X + c` with `c ≠ 0` on the recovery side
(`FactoringLab.symSpec_X_add_C`), recovering the affine dichotomy as the
degree-`1` instance of the general theorem.
-/
import Mathlib
import Probability.SymmetryCircularity

open Polynomial

namespace FactoringLab

/-! ### The generic symmetric coordinate ring `ℤ[N][s]` -/

/-- The ring `ℤ[N][s]` of the symmetric coordinates: the outer variable `X` is
the sum `s = p + q`, the inner variable (accessed as `nVar = C X`) is the
product `N = p q`. -/
abbrev SN := Polynomial (Polynomial ℤ)

/-- The product coordinate `N` inside `ℤ[N][s]`. -/
noncomputable def nVar : SN := C X

/-- The reduction data of `X^k` modulo `X² − s X + N`, as a pair
`(A_k, B_k)` with `X^k ≡ B_k X + A_k`.  The recursion is the one forced by
`X² ≡ s X − N`. -/
noncomputable def redPair : ℕ → SN × SN
  | 0 => (1, 0)
  | k + 1 => (-nVar * (redPair k).2, (redPair k).2 * X + (redPair k).1)

/-- Constant term of the reduction of `X^k`. -/
noncomputable def redA (k : ℕ) : SN := (redPair k).1

/-- Linear coefficient ("reduction slope") of the reduction of `X^k`. -/
noncomputable def redB (k : ℕ) : SN := (redPair k).2

@[simp] theorem redA_zero : redA 0 = 1 := rfl
@[simp] theorem redB_zero : redB 0 = 0 := rfl
theorem redA_succ (k : ℕ) : redA (k + 1) = -nVar * redB k := rfl
theorem redB_succ (k : ℕ) : redB (k + 1) = redB k * X + redA k := rfl

theorem degree_nVar : (nVar : SN).degree = 0 := by
  simp [nVar, degree_C]

/-- Degree bookkeeping for the reduction data: `deg_s A_k ≤ k` and
`deg_s B_k < k`. -/
theorem red_degrees (k : ℕ) : (redA k).degree ≤ (k : ℕ) ∧ (redB k).degree < (k : ℕ) := by
  induction k with
  | zero => constructor <;> simp [redA, redB, redPair]
  | succ k ih =>
      obtain ⟨hA, hB⟩ := ih
      refine ⟨?_, ?_⟩
      · rw [redA_succ]
        refine (degree_mul_le _ _).trans ?_
        rw [degree_neg, degree_nVar, zero_add]
        exact le_of_lt (hB.trans_le (by exact_mod_cast Nat.le_succ k))
      · rw [redB_succ]
        refine lt_of_le_of_lt (degree_add_le _ _) ?_
        rw [max_lt_iff]
        refine ⟨?_, lt_of_le_of_lt hA (by exact_mod_cast Nat.lt_succ_self k)⟩
        refine lt_of_le_of_lt (degree_mul_le _ _) ?_
        rw [degree_X]
        rcases eq_or_ne (redB k) 0 with h | h
        · simp [h]
        · rw [degree_eq_natDegree h] at hB ⊢
          have hlt : (redB k).natDegree < k := by exact_mod_cast hB
          have hcast : ((redB k).natDegree : WithBot ℕ) + 1
              = (((redB k).natDegree + 1 : ℕ) : WithBot ℕ) := by push_cast; ring
          rw [hcast]
          exact_mod_cast Nat.succ_lt_succ hlt

/-- Specialization `s ↦ p + q`, `N ↦ p q` of the symmetric coordinate ring. -/
noncomputable def evAt (p q : ℤ) : SN →+* ℤ :=
  (evalRingHom (p + q)).comp (mapRingHom (evalRingHom (p * q)))

@[simp] theorem evAt_X (p q : ℤ) : evAt p q X = p + q := by simp [evAt]
@[simp] theorem evAt_nVar (p q : ℤ) : evAt p q nVar = p * q := by simp [evAt, nVar]
@[simp] theorem evAt_CC (p q : ℤ) (c : ℤ) : evAt p q (C (C c)) = c := by simp [evAt]

/-- The defining property of the reduction data: after specializing the
symmetric coordinates at a root `r` of `X² − (p+q)X + pq`, the affine form
`B_k X + A_k` reproduces `r^k`. -/
theorem red_eval (p q r : ℤ) (h : r * r = (p + q) * r - p * q) (k : ℕ) :
    evAt p q (redB k) * r + evAt p q (redA k) = r ^ k := by
  induction k with
  | zero => simp
  | succ k ih =>
      rw [redA_succ, redB_succ]
      simp only [map_add, map_mul, map_neg, evAt_X, evAt_nVar]
      rw [pow_succ]
      linear_combination r * ih - evAt p q (redB k) * h

/-! ### The generic reduction of an arbitrary polynomial invariant -/

/-- Generic constant term of the reduction of `F` modulo `X² − sX + N`. -/
noncomputable def symA (F : Polynomial ℤ) : SN :=
  ∑ i ∈ Finset.range (F.natDegree + 1), C (C (F.coeff i)) * redA i

/-- Generic reduction slope of `F` modulo `X² − sX + N`. -/
noncomputable def symB (F : Polynomial ℤ) : SN :=
  ∑ i ∈ Finset.range (F.natDegree + 1), C (C (F.coeff i)) * redB i

/-- **Generic affine reduction.**  At either factor, `F` agrees with the affine
form determined by its generic reduction data. -/
theorem eval_eq_affine (F : Polynomial ℤ) (p q r : ℤ) (h : r * r = (p + q) * r - p * q) :
    F.eval r = evAt p q (symB F) * r + evAt p q (symA F) := by
  rw [Polynomial.eval_eq_sum_range]
  simp only [symA, symB, map_sum, map_mul, evAt_CC, Finset.sum_mul, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  have hi := red_eval p q r h i
  linear_combination (-(F.coeff i)) * hi

/-- The universal invariant polynomial `Ψ_F(s, N) = A_F² + A_F B_F s + B_F² N`
in the symmetric coordinates. -/
noncomputable def symPoly (F : Polynomial ℤ) : SN :=
  symA F ^ 2 + symA F * symB F * X + symB F ^ 2 * nVar

/-- **Universality of `Ψ_F`.**  For every polynomial `F` and *all* integers
`p, q`, the multiplicative invariant `F(p) F(q)` is the value of the single
polynomial `Ψ_F` at the symmetric coordinates `(p+q, pq)`. -/
theorem symPoly_eval (F : Polynomial ℤ) (p q : ℤ) :
    evAt p q (symPoly F) = F.eval p * F.eval q := by
  have hp : F.eval p = evAt p q (symB F) * p + evAt p q (symA F) :=
    eval_eq_affine F p q p (by ring)
  have hq : F.eval q = evAt p q (symB F) * q + evAt p q (symA F) :=
    eval_eq_affine F p q q (by ring)
  rw [hp, hq]
  simp only [symPoly, map_add, map_mul, map_pow, evAt_X, evAt_nVar]
  ring

/-! ### Degree bounds -/

theorem degree_symA_le (F : Polynomial ℤ) : (symA F).degree ≤ (F.natDegree : ℕ) := by
  refine (degree_sum_le _ _).trans (Finset.sup_le fun i hi => ?_)
  refine (degree_mul_le _ _).trans ?_
  have h1 : (C (C (F.coeff i)) : SN).degree ≤ 0 := degree_C_le
  have h2 : (redA i).degree ≤ (i : ℕ) := (red_degrees i).1
  have h3 : ((i : ℕ) : WithBot ℕ) ≤ ((F.natDegree : ℕ) : WithBot ℕ) := by
    have : i ≤ F.natDegree := Nat.lt_succ_iff.1 (Finset.mem_range.1 hi)
    exact_mod_cast this
  calc (C (C (F.coeff i)) : SN).degree + (redA i).degree ≤ 0 + (F.natDegree : ℕ) :=
        add_le_add h1 (h2.trans h3)
    _ = (F.natDegree : ℕ) := zero_add _

theorem degree_symB_lt (F : Polynomial ℤ) : (symB F).degree < (F.natDegree : ℕ) := by
  refine lt_of_le_of_lt (degree_sum_le _ _) ?_
  rw [Finset.sup_lt_iff (by exact_mod_cast WithBot.bot_lt_coe _)]
  intro i hi
  refine lt_of_le_of_lt (degree_mul_le _ _) ?_
  have h1 : (C (C (F.coeff i)) : SN).degree ≤ 0 := degree_C_le
  have h2 : (redB i).degree < (i : ℕ) := (red_degrees i).2
  have h3 : ((i : ℕ) : WithBot ℕ) ≤ ((F.natDegree : ℕ) : WithBot ℕ) := by
    have : i ≤ F.natDegree := Nat.lt_succ_iff.1 (Finset.mem_range.1 hi)
    exact_mod_cast this
  calc (C (C (F.coeff i)) : SN).degree + (redB i).degree ≤ 0 + (redB i).degree :=
        add_le_add h1 le_rfl
    _ = (redB i).degree := zero_add _
    _ < (F.natDegree : ℕ) := lt_of_lt_of_le h2 h3

theorem degree_symB_le (F : Polynomial ℤ) : (symB F).degree ≤ (F.natDegree : ℕ) :=
  le_of_lt (degree_symB_lt F)

/-- The reduction slope has `s`-degree strictly below `deg F`, in the form used
by the degree bound for `Ψ_F`. -/
theorem degree_symB_add_one_le (F : Polynomial ℤ) :
    (symB F).degree + 1 ≤ (F.natDegree : ℕ) := by
  rcases eq_or_ne (symB F) 0 with h | h
  · simp [h]
  · have hlt := degree_symB_lt F
    rw [degree_eq_natDegree h] at hlt ⊢
    have hnat : (symB F).natDegree < F.natDegree := by exact_mod_cast hlt
    have hcast : ((symB F).natDegree : WithBot ℕ) + 1
        = (((symB F).natDegree + 1 : ℕ) : WithBot ℕ) := by push_cast; ring
    rw [hcast]
    exact_mod_cast Nat.succ_le_of_lt hnat

/-- **Degree bound.**  The universal invariant polynomial has `s`-degree at most
`2 deg F`; this is the source of the "at most `2 deg F` candidate sums" in the
recovery branch of the dichotomy. -/
theorem degree_symPoly_le (F : Polynomial ℤ) :
    (symPoly F).degree ≤ ((2 * F.natDegree : ℕ) : ℕ) := by
  have hA := degree_symA_le F
  have hB1 := degree_symB_add_one_le F
  have hBle := degree_symB_le F
  have h2 : ((F.natDegree : ℕ) : WithBot ℕ) + (F.natDegree : ℕ)
      = ((2 * F.natDegree : ℕ) : WithBot ℕ) := by push_cast; ring
  have hsq : (symA F ^ 2).degree ≤ ((2 * F.natDegree : ℕ) : WithBot ℕ) := by
    rw [sq]
    exact (degree_mul_le _ _).trans (by rw [← h2]; exact add_le_add hA hA)
  have hmid : (symA F * symB F * X).degree ≤ ((2 * F.natDegree : ℕ) : WithBot ℕ) := by
    calc (symA F * symB F * X).degree
        ≤ (symA F * symB F).degree + (X : SN).degree := degree_mul_le _ _
      _ ≤ ((symA F).degree + (symB F).degree) + 1 := by
          rw [degree_X]; exact add_le_add (degree_mul_le _ _) le_rfl
      _ = (symA F).degree + ((symB F).degree + 1) := add_assoc _ _ _
      _ ≤ ((F.natDegree : ℕ) : WithBot ℕ) + (F.natDegree : ℕ) := add_le_add hA hB1
      _ = ((2 * F.natDegree : ℕ) : WithBot ℕ) := h2
  have hlast : (symB F ^ 2 * nVar).degree ≤ ((2 * F.natDegree : ℕ) : WithBot ℕ) := by
    refine (degree_mul_le _ _).trans ?_
    rw [degree_nVar, add_zero, sq]
    exact (degree_mul_le _ _).trans (by rw [← h2]; exact add_le_add hBle hBle)
  refine (degree_add_le _ _).trans (max_le ((degree_add_le _ _).trans (max_le hsq hmid)) hlast)


/-! ### The dichotomy -/

/-- The invariant polynomial specialized at a known modulus `N`: a polynomial in
the single unknown `s = p + q`, with integer coefficients computable from `N`
alone. -/
noncomputable def symSpec (F : Polynomial ℤ) (N : ℤ) : Polynomial ℤ :=
  (symPoly F).map (evalRingHom N)

theorem symSpec_eval (F : Polynomial ℤ) (p q : ℤ) :
    (symSpec F (p * q)).eval (p + q) = F.eval p * F.eval q := symPoly_eval F p q

theorem natDegree_symSpec_le (F : Polynomial ℤ) (N : ℤ) :
    (symSpec F N).natDegree ≤ 2 * F.natDegree := by
  refine le_trans (natDegree_map_le) ?_
  exact natDegree_le_iff_degree_le.2 (degree_symPoly_le F)

/-- **The multiplicative dichotomy in arbitrary degree** (Conjecture B).
Fix a polynomial invariant `F` and a modulus `N`, and let
`ψ = Ψ_F(·, N) ∈ ℤ[s]` be the specialized invariant polynomial.  Exactly one of
the following holds.

* `ψ` is constant.  Then `F(p) F(q) = ψ(0)` for **every** factorization
  `N = p q`: the invariant is `N`-only in the strongest sense, taking one and
  the same value on all factor pairs of `N`.
* `ψ` is nonconstant, of degree at most `2 deg F`.  Then for every
  factorization `N = p q` the sum `s = p + q` is a root of the *nonzero*
  polynomial `ψ − F(p)F(q)`, which has at most `2 deg F` roots; so the hidden
  sum is one of at most `2 deg F` explicitly computable candidates. -/
theorem general_degree_dichotomy (F : Polynomial ℤ) (N : ℤ) :
    ((symSpec F N).natDegree = 0 ∧
        ∀ p q : ℤ, p * q = N → F.eval p * F.eval q = (symSpec F N).coeff 0) ∨
      (0 < (symSpec F N).natDegree ∧ (symSpec F N).natDegree ≤ 2 * F.natDegree ∧
        ∀ p q : ℤ, p * q = N →
          (symSpec F N - C (F.eval p * F.eval q)) ≠ 0 ∧
          (symSpec F N - C (F.eval p * F.eval q)).eval (p + q) = 0 ∧
          (symSpec F N - C (F.eval p * F.eval q)).roots.card ≤ 2 * F.natDegree) := by
  rcases Nat.eq_zero_or_pos (symSpec F N).natDegree with h0 | hpos
  · refine Or.inl ⟨h0, fun p q hpq => ?_⟩
    obtain ⟨a, ha⟩ := Polynomial.natDegree_eq_zero.1 h0
    have hval : (symSpec F N).eval (p + q) = F.eval p * F.eval q := by
      rw [← hpq]; exact symSpec_eval F p q
    rw [← hval, ← ha]
    simp
  · refine Or.inr ⟨hpos, natDegree_symSpec_le F N, fun p q hpq => ?_⟩
    have hval : (symSpec F N).eval (p + q) = F.eval p * F.eval q := by
      rw [← hpq]; exact symSpec_eval F p q
    set T := F.eval p * F.eval q with hT
    have hdegC : (C T : Polynomial ℤ).degree ≤ 0 := degree_C_le
    have hdeg : (symSpec F N - C T).natDegree = (symSpec F N).natDegree := by
      refine natDegree_sub_eq_left_of_natDegree_lt ?_
      simpa using hpos
    have hne : symSpec F N - C T ≠ 0 := by
      intro h
      rw [h] at hdeg
      simp at hdeg
      omega
    refine ⟨hne, by simp [hval], ?_⟩
    calc (symSpec F N - C T).roots.card ≤ (symSpec F N - C T).natDegree :=
          (symSpec F N - C T).card_roots'
      _ = (symSpec F N).natDegree := hdeg
      _ ≤ 2 * F.natDegree := natDegree_symSpec_le F N

/-- **Recovery from a candidate sum.**  On the nonconstant side of the
dichotomy, the hidden sum `p + q` is a root of an explicit polynomial of degree
at most `2 deg F` whose coefficients depend only on `N` and the observed
invariant value; each root determines a candidate factorization in closed form,
so factoring costs a search over at most `2 deg F` candidates. -/
theorem general_degree_recovery (F : Polynomial ℤ) {p q : ℤ} (hpq : p ≤ q)
    (hpos : 0 < (symSpec F (p * q)).natDegree) :
    (p + q) ∈ (symSpec F (p * q) - C (F.eval p * F.eval q)).roots ∧
      ((p + q) - (Int.sqrt ((p + q) ^ 2 - 4 * (p * q)) : ℤ)) / 2 = p ∧
      ((p + q) + (Int.sqrt ((p + q) ^ 2 - 4 * (p * q)) : ℤ)) / 2 = q := by
  rcases general_degree_dichotomy F (p * q) with ⟨h0, -⟩ | ⟨-, -, hrec⟩
  · omega
  · obtain ⟨hne, hroot, -⟩ := hrec p q rfl
    refine ⟨?_, ?_, ?_⟩
    · exact (mem_roots hne).2 (by simpa [IsRoot] using hroot)
    · exact (recovery_from_sum hpq (rfl : p * q = p * q) (rfl : p + q = p + q)).2.1
    · exact (recovery_from_sum hpq (rfl : p * q = p * q) (rfl : p + q = p + q)).2.2

/-! ### Both branches occur -/

@[simp] theorem symA_X : symA (X : Polynomial ℤ) = 0 := by
  unfold symA
  rw [natDegree_X, Finset.sum_range_succ, Finset.sum_range_one]
  simp [redA_succ]

@[simp] theorem symB_X : symB (X : Polynomial ℤ) = 1 := by
  unfold symB
  rw [natDegree_X, Finset.sum_range_succ, Finset.sum_range_one]
  simp [redB_succ]

/-- The identity invariant `F = X` is on the `N`-only side: `F(p)F(q) = N` for
every factorization, and indeed `Ψ_X(·, N)` is the constant `N`. -/
theorem symSpec_X (N : ℤ) : symSpec (X : Polynomial ℤ) N = C N := by
  simp [symSpec, symPoly, nVar]

theorem symSpec_X_isNOnly (N : ℤ) : (symSpec (X : Polynomial ℤ) N).natDegree = 0 := by
  rw [symSpec_X]; exact natDegree_C N

/-- The affine invariant `F = X + c` with `c ≠ 0` is on the recovery side: the
specialized invariant polynomial is `c s + (c² + N)`, of degree `1`, whose
unique root is the hidden sum.  This recovers the affine dichotomy of
`MultiplicativeDichotomy.lean` as the degree-`1` instance of the general
theorem. -/
theorem symSpec_X_add_C (c N : ℤ) :
    symSpec (X + C c) N = C c * X + C (c ^ 2 + N) := by
  have hdeg : (X + C c : Polynomial ℤ).natDegree = 1 := natDegree_X_add_C c
  have hc0 : (X + C c : Polynomial ℤ).coeff 0 = c := by simp
  have hc1 : (X + C c : Polynomial ℤ).coeff 1 = 1 := by
    rw [coeff_add, coeff_X_one, coeff_C]
    norm_num
  have hA : symA (X + C c) = C (C c) := by
    unfold symA
    rw [hdeg, Finset.sum_range_succ, Finset.sum_range_one, hc0, hc1]
    simp [redA_succ]
  have hB : symB (X + C c) = 1 := by
    unfold symB
    rw [hdeg, Finset.sum_range_succ, Finset.sum_range_one, hc0, hc1]
    simp [redB_succ]
  simp only [symSpec, symPoly, hA, hB, nVar]
  simp [Polynomial.map_add, Polynomial.map_mul, Polynomial.map_pow]
  ring

theorem symSpec_X_add_C_recovers (c N : ℤ) (hc : c ≠ 0) :
    0 < (symSpec (X + C c) N).natDegree := by
  rw [symSpec_X_add_C]
  have : (C c * X + C (c ^ 2 + N) : Polynomial ℤ).natDegree = 1 := by
    rw [natDegree_add_C]
    exact natDegree_C_mul_X c hc
  omega

/-! ### A worked instance -/

/-- The universal polynomial of `F = X² + 1`, computed generically:
`Ψ_F = s² + (1 − N)²`.  Note that its `s`-degree is `2`, well inside the bound
`2 deg F = 4`. -/
theorem symSpec_sq_add_one (N : ℤ) :
    symSpec (X ^ 2 + C 1) N = X ^ 2 + C ((1 - N) ^ 2) := by
  have hdeg : (X ^ 2 + C (1 : ℤ)).natDegree = 2 := by
    simpa using natDegree_X_pow_add_C (n := 2) (r := (1 : ℤ))
  have hc0 : (X ^ 2 + C (1 : ℤ)).coeff 0 = 1 := by
    rw [coeff_add, coeff_X_pow, coeff_C]
    norm_num
  have hc1 : (X ^ 2 + C (1 : ℤ)).coeff 1 = 0 := by
    rw [coeff_add, coeff_X_pow, coeff_C]
    norm_num
  have hc2 : (X ^ 2 + C (1 : ℤ)).coeff 2 = 1 := by
    rw [coeff_add, coeff_X_pow, coeff_C]
    norm_num
  have hA : symA (X ^ 2 + C 1) = 1 - nVar := by
    unfold symA
    rw [hdeg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
      hc0, hc1, hc2]
    simp [redA_succ, redB_succ]
    ring
  have hB : symB (X ^ 2 + C 1) = X := by
    unfold symB
    rw [hdeg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
      hc0, hc1, hc2]
    simp [redB_succ, redA_succ]
  simp only [symSpec, symPoly, hA, hB, nVar]
  simp [Polynomial.map_add, Polynomial.map_mul, Polynomial.map_pow, Polynomial.map_sub]
  ring

/-- Numerical check of the universal identity at the semiprime `15 = 3 · 5`
with the invariant `F = X² + 1`: `Ψ_F(8, 15) = F(3) F(5) = 10 · 26 = 260`. -/
theorem symSpec_example : (symSpec (X ^ 2 + C 1) 15).eval 8 = 260 := by
  rw [symSpec_sq_add_one]
  norm_num

/-- The same instance seen through the dichotomy: the candidate polynomial
`Ψ_F(·, 15) − 260 = s² − 64` is nonzero of degree `2`, and the hidden sum
`3 + 5 = 8` is one of its (two) roots. -/
theorem symSpec_example_candidate :
    symSpec (X ^ 2 + C 1) 15 - C 260 = X ^ 2 - C 64 ∧
      (X ^ 2 - C (64 : ℤ)).eval 8 = 0 := by
  refine ⟨?_, by norm_num⟩
  rw [symSpec_sq_add_one]
  norm_num
  ring

end FactoringLab