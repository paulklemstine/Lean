/-
# Simplex-lattice unisolvence: optimal node sets for total-degree chart identities

`Bridges.ChartDegreeExactness` certifies an identity between chart expressions of total
degree `≤ d` by checking it on the box grid `{0,…,d}^n`, which costs `(d+1)^n` points,
while `Bridges.ChartUniquenessDimension` shows that *any* uniqueness set must have at least
`#(monomialsLE n d)` points.  This file closes the gap: the **simplex lattice**

  `S(n,d) = { a ∈ ℕⁿ : a₀ + ⋯ + a_{n-1} ≤ d }`

is already a uniqueness set, and it has exactly `#(monomialsLE n d)` points, so it is a
*minimum-cardinality* uniqueness set.

The proof of unisolvence is a double induction on the degree `d` and the number `n` of
variables.  For the step one substitutes `x₀ ↦ d - (x₁ + ⋯ + x_{n-1})`; the resulting
polynomial in `n-1` variables again has total degree `≤ d` and vanishes on the simplex
lattice of its own dimension, so it is zero by the inner induction hypothesis.  Hence the
linear form `x₀ + ⋯ + x_{n-1} - d` divides `p`, the cofactor has total degree `≤ d-1` and
vanishes on `S(n, d-1)`, and the outer induction hypothesis finishes the argument.

Main results:
* `ChartCalculus.simplex_unisolvent_of_castNeZero` — a polynomial of total degree `≤ d`
  over a domain in which `1, …, d` are nonzero and which vanishes on `S(n,d)` is zero.
* `ChartCalculus.simplex_unisolvent` — the characteristic-zero form.
* `ChartCalculus.simplex_unisolvent_of_lt_ringChar` — the form valid below the
  characteristic (`d < ringChar K`), together with
  `ChartCalculus.simplex_not_unisolvent_of_char_le`, which shows that `d < p` is an exact
  criterion in prime characteristic `p`.
* `ChartCalculus.eq_of_eval_eq_on_simplex` — the two-polynomial form.
* `ChartCalculus.card_simplexPoints` — the simplex node set has exactly as many points as
  there are monomials of total degree `≤ d`.
* `ChartCalculus.simplexPoints_is_minimum_uniqueness_set` — it is a uniqueness set and no
  uniqueness set is smaller.
* `ChartCalculus.card_simplexNodes_lt_grid` — for `n ≥ 2`, `d ≥ 1` it is strictly smaller
  than the box grid `{0,…,d}^n`.
* `ChartCalculus.NExpr.simplex_degree_exact` — the reflective-calculus consequence: a
  simplex-lattice check certifies an identity in *every* commutative ring.
-/
import Bridges.ChartUniquenessDimension

open MvPolynomial

namespace ChartCalculus

/-! ## Two small degree facts -/

section Basic

variable {K : Type*} [CommRing K]

/-- A polynomial of total degree `0` that vanishes somewhere is zero. -/
theorem eq_zero_of_totalDegree_zero {σ : Type*} {p : MvPolynomial σ K}
    (h : p.totalDegree = 0) (x : σ → K) (hv : eval x p = 0) : p = 0 := by
  rw [MvPolynomial.totalDegree_eq_zero_iff_eq_C] at h
  rw [h] at hv ⊢
  simp only [eval_C] at hv
  simp [hv]

/-- Every polynomial in zero variables has total degree `0`. -/
theorem totalDegree_fin_zero (p : MvPolynomial (Fin 0) K) : p.totalDegree = 0 := by
  refine Nat.le_zero.mp ?_
  rw [MvPolynomial.totalDegree]
  refine Finset.sup_le (fun m _ => ?_)
  have hm : m = 0 := Subsingleton.elim _ _
  simp [hm]

/-- Substituting a polynomial of total degree `≤ 1` for the first variable does not raise
the total degree.  The substitution is performed through `finSuccEquiv`: evaluating the
one-variable polynomial `finSuccEquiv K n p` at `L`. -/
theorem totalDegree_polyEval_le {n : ℕ} (p : MvPolynomial (Fin (n + 1)) K)
    (L : MvPolynomial (Fin n) K) (hL : L.totalDegree ≤ 1) :
    (Polynomial.eval L (finSuccEquiv K n p)).totalDegree ≤ p.totalDegree := by
  rw [Polynomial.eval_eq_sum_range]
  refine (MvPolynomial.totalDegree_finset_sum _ _).trans (Finset.sup_le (fun i _ => ?_))
  by_cases h : (finSuccEquiv K n p).coeff i = 0
  · simp [h]
  · have hcoeff := MvPolynomial.totalDegree_coeff_finSuccEquiv_add_le p i h
    have hpow : (L ^ i).totalDegree ≤ i := by
      refine (MvPolynomial.totalDegree_pow L i).trans ?_
      calc i * L.totalDegree ≤ i * 1 := Nat.mul_le_mul_left i hL
        _ = i := by ring
    have hmul := MvPolynomial.totalDegree_mul ((finSuccEquiv K n p).coeff i) (L ^ i)
    omega

end Basic

/-! ## The two linear forms cutting out the simplex face -/

section LinForms

variable (K : Type*) [CommRing K]

/-- The solved form `d - (x₀ + ⋯ + x_{n-1})` in `n` variables. -/
noncomputable def linLower (n d : ℕ) : MvPolynomial (Fin n) K := C ((d : ℕ) : K) - ∑ i, X i

/-- The affine form `x₀ + ⋯ + x_n - d` in `n+1` variables, whose zero locus is the
hyperplane carrying the top face of the simplex. -/
noncomputable def linFull (n d : ℕ) : MvPolynomial (Fin (n + 1)) K := (∑ i, X i) - C ((d : ℕ) : K)

variable {K}

@[simp] theorem eval_linLower {n d : ℕ} (x : Fin n → K) :
    eval x (linLower K n d) = ((d : ℕ) : K) - ∑ i, x i := by
  simp [linLower]

@[simp] theorem eval_linFull {n d : ℕ} (x : Fin (n + 1) → K) :
    eval x (linFull K n d) = (∑ i, x i) - ((d : ℕ) : K) := by
  simp [linFull]

theorem totalDegree_linLower_le [Nontrivial K] (n d : ℕ) :
    (linLower K n d).totalDegree ≤ 1 := by
  rw [linLower, sub_eq_add_neg]
  refine (MvPolynomial.totalDegree_add _ _).trans (max_le ?_ ?_)
  · exact le_of_eq_of_le (MvPolynomial.totalDegree_C _) (by norm_num)
  · rw [MvPolynomial.totalDegree_neg]
    refine (MvPolynomial.totalDegree_finset_sum _ _).trans (Finset.sup_le (fun i _ => ?_))
    exact le_of_eq (MvPolynomial.totalDegree_X i)

theorem finSuccEquiv_linFull (n d : ℕ) :
    finSuccEquiv K n (linFull K n d) = Polynomial.X - Polynomial.C (linLower K n d) := by
  have h1 : finSuccEquiv K n (∑ i : Fin (n + 1), X i)
      = Polynomial.X + Polynomial.C (∑ i : Fin n, X i) := by
    rw [Fin.sum_univ_succ, map_add, MvPolynomial.finSuccEquiv_X_zero, map_sum, map_sum]
    congr 1
    exact Finset.sum_congr rfl (fun i _ => MvPolynomial.finSuccEquiv_X_succ)
  have h2 : finSuccEquiv K n (C (((d : ℕ) : K))) = Polynomial.C (C (((d : ℕ) : K))) := by
    simp
  rw [linFull, linLower, map_sub, h1, h2, map_sub]
  ring

theorem one_le_totalDegree_linFull [Nontrivial K] (n d : ℕ) :
    1 ≤ (linFull K n d).totalDegree := by
  by_contra hcon
  push_neg at hcon
  have h0 : (linFull K n d).totalDegree = 0 := by omega
  rw [MvPolynomial.totalDegree_eq_zero_iff_eq_C] at h0
  have e0 := congrArg (eval (fun _ => (0 : K))) h0
  have e1 := congrArg (eval (fun i => if i = 0 then (1 : K) else 0)) h0
  rw [eval_linFull] at e0 e1
  rw [eval_C] at e0 e1
  rw [Finset.sum_const_zero] at e0
  rw [Finset.sum_ite_eq' Finset.univ (0 : Fin (n + 1)) (fun _ => (1 : K))] at e1
  simp only [Finset.mem_univ, if_true] at e1
  have hone : (1 : K) = 0 := sub_left_inj.mp (e1.trans e0.symm)
  exact one_ne_zero hone

theorem linFull_ne_zero [Nontrivial K] (n d : ℕ) : linFull K n d ≠ 0 := by
  intro h
  have := one_le_totalDegree_linFull (K := K) n d
  rw [h] at this
  simp at this

end LinForms

/-! ## The unisolvence theorem -/

section Unisolvence

variable {K : Type*} [CommRing K] [IsDomain K]

/-- **Simplex-lattice unisolvence, general form.**  Over an integral domain in which the
integers `1, …, d` are nonzero, a polynomial in `n` variables of total degree `≤ d` that
vanishes at every lattice point `a ∈ ℕⁿ` with `a₀ + ⋯ + a_{n-1} ≤ d` is the zero
polynomial.  The hypothesis on the characteristic is used exactly once, to know that the
affine form `x₀ + ⋯ + x_{n-1} - d` does not vanish at the points of the smaller
simplex. -/
theorem simplex_unisolvent_of_castNeZero :
    ∀ (d n : ℕ) (p : MvPolynomial (Fin n) K), (∀ m : ℕ, 0 < m → m ≤ d → (m : K) ≠ 0) →
      p.totalDegree ≤ d →
      (∀ a : Fin n → ℕ, ∑ i, a i ≤ d → eval (fun i => ((a i : ℕ) : K)) p = 0) → p = 0 := by
  intro d
  induction d with
  | zero =>
      intro n p _ hdeg hvan
      exact eq_zero_of_totalDegree_zero (Nat.le_zero.mp hdeg) _ (hvan (fun _ => 0) (by simp))
  | succ d ihd =>
      intro n
      induction n with
      | zero =>
          intro p _ _ hvan
          exact eq_zero_of_totalDegree_zero (totalDegree_fin_zero p) _
            (hvan (fun _ => 0) (by simp))
      | succ n ihn =>
          intro p hchar hdeg hvan
          -- Step 1: the substitution `x₀ ↦ (d+1) - (x₁ + ⋯ + xₙ)` kills `p`.
          have hsubst : ∀ a : Fin n → ℕ, ∑ i, a i ≤ d + 1 →
              eval (fun i => ((a i : ℕ) : K))
                (Polynomial.eval (linLower K n (d + 1)) (finSuccEquiv K n p)) = 0 := by
            intro a ha
            have hcomm : eval (fun i => ((a i : ℕ) : K))
                  (Polynomial.eval (linLower K n (d + 1)) (finSuccEquiv K n p)) =
                Polynomial.eval (eval (fun i => ((a i : ℕ) : K)) (linLower K n (d + 1)))
                  (Polynomial.map (eval (fun i => ((a i : ℕ) : K))) (finSuccEquiv K n p)) :=
              (Polynomial.eval_map_apply (eval (fun i => ((a i : ℕ) : K))) _).symm
            have hLval : eval (fun i => ((a i : ℕ) : K)) (linLower K n (d + 1))
                = (((d + 1 - ∑ i, a i : ℕ) : ℕ) : K) := by
              rw [eval_linLower, Nat.cast_sub ha]
              push_cast
              ring
            rw [hcomm, hLval, ← MvPolynomial.eval_eq_eval_mv_eval']
            have hpt : (Fin.cons (((d + 1 - ∑ i, a i : ℕ) : ℕ) : K)
                  (fun i => ((a i : ℕ) : K)) : Fin (n + 1) → K)
                = fun j => (((Fin.cons (d + 1 - ∑ i, a i) a : Fin (n+1) → ℕ) j : ℕ) : K) := by
              funext j
              refine Fin.cases ?_ ?_ j <;> simp
            rw [hpt]
            refine hvan _ ?_
            rw [Fin.sum_cons]
            omega
          have hr : Polynomial.eval (linLower K n (d + 1)) (finSuccEquiv K n p) = 0 :=
            ihn _ hchar
              ((totalDegree_polyEval_le p _ (totalDegree_linLower_le n (d + 1))).trans hdeg)
              hsubst
          -- Step 2: the affine form therefore divides `p`.
          obtain ⟨Q, hQ⟩ := Polynomial.dvd_iff_isRoot.mpr hr
          have hfact : p = linFull K n (d + 1) * (finSuccEquiv K n).symm Q := by
            apply (finSuccEquiv K n).injective
            rw [map_mul, finSuccEquiv_linFull, hQ]
            simp
          set q : MvPolynomial (Fin (n + 1)) K := (finSuccEquiv K n).symm Q with hqdef
          -- Step 3: the cofactor vanishes on the smaller simplex.
          have hqvan : ∀ b : Fin (n + 1) → ℕ, ∑ i, b i ≤ d →
              eval (fun i => ((b i : ℕ) : K)) q = 0 := by
            intro b hb
            have hp0 : eval (fun i => ((b i : ℕ) : K)) p = 0 := hvan b (by omega)
            rw [hfact, map_mul] at hp0
            have hne : eval (fun i => ((b i : ℕ) : K)) (linFull K n (d + 1)) ≠ 0 := by
              rw [eval_linFull, sub_ne_zero]
              intro hcast
              refine hchar (d + 1 - ∑ i, b i) (by omega) (by omega) ?_
              rw [Nat.cast_sub (by omega)]
              push_cast at hcast ⊢
              rw [sub_eq_zero]
              exact hcast.symm
            rcases mul_eq_zero.mp hp0 with h | h
            · exact absurd h hne
            · exact h
          -- Step 4: degree bookkeeping and the outer induction hypothesis.
          rcases eq_or_ne q 0 with hq0 | hq0
          · rw [hfact, hq0, mul_zero]
          · exfalso
            have hdegq : q.totalDegree ≤ d := by
              have hmul := MvPolynomial.totalDegree_mul_of_isDomain
                (linFull_ne_zero (K := K) n (d + 1)) hq0
              rw [← hfact] at hmul
              have h1 := one_le_totalDegree_linFull (K := K) n (d + 1)
              omega
            exact hq0 (ihd (n + 1) q (fun m hm hmd => hchar m hm (by omega)) hdegq hqvan)

/-- **Simplex-lattice unisolvence in characteristic zero.** -/
theorem simplex_unisolvent [CharZero K] :
    ∀ (d n : ℕ) (p : MvPolynomial (Fin n) K), p.totalDegree ≤ d →
      (∀ a : Fin n → ℕ, ∑ i, a i ≤ d → eval (fun i => ((a i : ℕ) : K)) p = 0) → p = 0 :=
  fun d n p hdeg hvan =>
    simplex_unisolvent_of_castNeZero d n p
      (fun m hm _ => Nat.cast_ne_zero.mpr (by omega)) hdeg hvan

/-- **Simplex-lattice unisolvence below the characteristic.**  The simplex lattice is still
a uniqueness set for total degree `≤ d` over a domain of positive characteristic `p`, as
long as `d < p`. -/
theorem simplex_unisolvent_of_lt_ringChar {d n : ℕ} (hd : d < ringChar K)
    (p : MvPolynomial (Fin n) K) (hdeg : p.totalDegree ≤ d)
    (hvan : ∀ a : Fin n → ℕ, ∑ i, a i ≤ d → eval (fun i => ((a i : ℕ) : K)) p = 0) :
    p = 0 := by
  refine simplex_unisolvent_of_castNeZero d n p (fun m hm hmd hzero => ?_) hdeg hvan
  have hdvd : ringChar K ∣ m := (ringChar.spec K m).mp hzero
  have := Nat.le_of_dvd hm hdvd
  omega

/-- **The characteristic bound is sharp.**  Over a field of prime characteristic `p`, as
soon as `d ≥ p` (and there is at least one variable) the simplex lattice is *not* a
uniqueness set for total degree `≤ d`: the Artin–Schreier polynomial `x₀^p - x₀` is a
nonzero witness of total degree `p ≤ d` vanishing at every lattice point.  Together with
`simplex_unisolvent_of_lt_ringChar` this makes `d < p` an exact criterion. -/
theorem simplex_not_unisolvent_of_char_le {p : ℕ} [CharP K p] (hp : p.Prime) {n d : ℕ}
    (hn : 0 < n) (hd : p ≤ d) :
    ∃ q : MvPolynomial (Fin n) K, q ≠ 0 ∧ q.totalDegree ≤ d ∧
      ∀ a : Fin n → ℕ, ∑ i, a i ≤ d → eval (fun i => ((a i : ℕ) : K)) q = 0 := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : ExpChar K p := ExpChar.prime hp
  set i₀ : Fin n := ⟨0, hn⟩ with hi₀
  refine ⟨X i₀ ^ p - X i₀, ?_, ?_, ?_⟩
  · intro h
    have h2 := hp.two_le
    have hc := congrArg (MvPolynomial.coeff (Finsupp.single i₀ p)) h
    rw [MvPolynomial.coeff_sub, MvPolynomial.coeff_X_pow, MvPolynomial.coeff_X',
      MvPolynomial.coeff_zero, if_pos rfl] at hc
    rw [if_neg] at hc
    · simp at hc
    · intro hEq
      have hval := congrArg (fun f => f i₀) hEq
      simp at hval
      omega
  · refine (MvPolynomial.totalDegree_sub _ _).trans (max_le ?_ ?_)
    · refine (MvPolynomial.totalDegree_pow _ _).trans ?_
      simp only [MvPolynomial.totalDegree_X, mul_one]
      exact hd
    · simp only [MvPolynomial.totalDegree_X]
      have := hp.two_le
      omega
  · intro a _
    have hfrob : (((a i₀ : ℕ) : K)) ^ p = ((a i₀ : ℕ) : K) := by
      have hmap := map_natCast (frobenius K p) (a i₀)
      rwa [frobenius_def] at hmap
    simp only [map_sub, MvPolynomial.eval_pow, MvPolynomial.eval_X]
    rw [hfrob, sub_self]

variable [CharZero K]

/-- Two polynomials of total degree `≤ d` that agree on the simplex lattice are equal. -/
theorem eq_of_eval_eq_on_simplex {n d : ℕ} (p q : MvPolynomial (Fin n) K)
    (hp : p.totalDegree ≤ d) (hq : q.totalDegree ≤ d)
    (h : ∀ a : Fin n → ℕ, ∑ i, a i ≤ d →
      eval (fun i => ((a i : ℕ) : K)) p = eval (fun i => ((a i : ℕ) : K)) q) :
    p = q := by
  have hdeg : (p - q).totalDegree ≤ d := by
    rw [sub_eq_add_neg]
    exact (MvPolynomial.totalDegree_add p (-q)).trans
      (max_le hp (by rwa [MvPolynomial.totalDegree_neg]))
  have hzero : p - q = 0 := by
    refine simplex_unisolvent d n (p - q) hdeg (fun a ha => ?_)
    simp only [map_sub, sub_eq_zero]
    exact h a ha
  exact sub_eq_zero.mp hzero

end Unisolvence

/-! ## The simplex node set and its cardinality -/

/-- The simplex lattice `{ a ∈ ℕⁿ : ∑ aᵢ ≤ d }`, obtained from the monomials of total
degree `≤ d` by forgetting the `Finsupp` structure. -/
noncomputable def simplexNodes (n d : ℕ) : Finset (Fin n → ℕ) :=
  (monomialsLE n d).image (fun m => fun i => m i)

theorem finsupp_sum_eq_sum {n : ℕ} (m : Fin n →₀ ℕ) : (m.sum fun _ e => e) = ∑ i, m i := by
  rw [Finsupp.sum_fintype _ _ (fun _ => rfl)]

@[simp] theorem mem_simplexNodes {n d : ℕ} {a : Fin n → ℕ} :
    a ∈ simplexNodes n d ↔ ∑ i, a i ≤ d := by
  classical
  constructor
  · intro ha
    obtain ⟨m, hm, rfl⟩ := Finset.mem_image.mp ha
    have hsum := mem_monomialsLE.mp hm
    rwa [finsupp_sum_eq_sum] at hsum
  · intro ha
    refine Finset.mem_image.mpr ⟨Finsupp.equivFunOnFinite.symm a, ?_, ?_⟩
    · refine mem_monomialsLE.mpr ?_
      rw [finsupp_sum_eq_sum]
      simpa using ha
    · funext i; simp

/-- The simplex node set has exactly as many points as there are monomials of total
degree `≤ d`: it meets the dimension lower bound of
`ChartCalculus.uniqueness_set_card_ge` exactly. -/
theorem card_simplexNodes (n d : ℕ) : (simplexNodes n d).card = (monomialsLE n d).card := by
  classical
  refine Finset.card_image_of_injective _ (fun m m' h => ?_)
  exact Finsupp.ext (fun i => congrFun h i)

/-- The box grid `{0,…,d}^n` as a finset of natural-number tuples. -/
def boxNodes (n d : ℕ) : Finset (Fin n → ℕ) :=
  Fintype.piFinset (fun _ : Fin n => Finset.range (d + 1))

theorem card_boxNodes (n d : ℕ) : (boxNodes n d).card = (d + 1) ^ n := by
  simp [boxNodes]

theorem simplexNodes_subset_boxNodes (n d : ℕ) : simplexNodes n d ⊆ boxNodes n d := by
  intro a ha
  have hsum := mem_simplexNodes.mp ha
  refine Fintype.mem_piFinset.mpr (fun i => Finset.mem_range.mpr ?_)
  have hle : a i ≤ ∑ j, a j := Finset.single_le_sum (f := fun j => a j)
    (fun j _ => Nat.zero_le _) (Finset.mem_univ i)
  omega

/-- **Strict saving.**  As soon as there are at least two variables and the degree is
positive, the simplex node set is strictly smaller than the box grid `{0,…,d}^n`. -/
theorem card_simplexNodes_lt_grid {n d : ℕ} (hn : 2 ≤ n) (hd : 1 ≤ d) :
    (simplexNodes n d).card < (d + 1) ^ n := by
  classical
  rw [← card_boxNodes n d]
  refine Finset.card_lt_card ⟨simplexNodes_subset_boxNodes n d, ?_⟩
  intro hsub
  set i₀ : Fin n := ⟨0, by omega⟩ with hi₀
  set i₁ : Fin n := ⟨1, by omega⟩ with hi₁
  set a : Fin n → ℕ := fun i => if i = i₀ ∨ i = i₁ then d else 0 with hadef
  have hbox : a ∈ boxNodes n d := by
    refine Fintype.mem_piFinset.mpr (fun i => Finset.mem_range.mpr ?_)
    by_cases h : i = i₀ ∨ i = i₁ <;> simp [hadef, h]

  have hsimp := mem_simplexNodes.mp (hsub hbox)
  have hne : i₀ ≠ i₁ := by
    intro h
    have hval := congrArg Fin.val h
    simp [hi₀, hi₁] at hval
  have hpair : a i₀ + a i₁ ≤ ∑ i, a i := by
    calc a i₀ + a i₁ = ∑ i ∈ ({i₀, i₁} : Finset (Fin n)), a i := (Finset.sum_pair hne).symm
      _ ≤ ∑ i, a i := Finset.sum_le_sum_of_subset (Finset.subset_univ _)
  have h0 : a i₀ = d := by simp [hadef]
  have h1 : a i₁ = d := by simp [hadef]
  rw [h0, h1] at hpair
  omega

/-! ## Optimality over a field -/

section Optimal

open Classical in
/-- The image of the simplex lattice in `Kⁿ`. -/
noncomputable def simplexPoints (K : Type*) [Field K] [CharZero K] (n d : ℕ) :
    Finset (Fin n → K) :=
  (simplexNodes n d).image (fun a => fun i => ((a i : ℕ) : K))

variable {K : Type*} [Field K] [CharZero K]

theorem mem_simplexPoints {n d : ℕ} {t : Fin n → K} :
    t ∈ simplexPoints K n d ↔
      ∃ a : Fin n → ℕ, ∑ i, a i ≤ d ∧ (fun i => ((a i : ℕ) : K)) = t := by
  classical
  rw [simplexPoints, Finset.mem_image]
  constructor
  · rintro ⟨a, ha, rfl⟩
    exact ⟨a, mem_simplexNodes.mp ha, rfl⟩
  · rintro ⟨a, ha, rfl⟩
    exact ⟨a, mem_simplexNodes.mpr ha, rfl⟩

theorem card_simplexPoints (n d : ℕ) :
    (simplexPoints K n d).card = (monomialsLE n d).card := by
  classical
  rw [simplexPoints, Finset.card_image_of_injective, card_simplexNodes]
  intro a a' h
  funext i
  have hcast : ((a i : ℕ) : K) = ((a' i : ℕ) : K) := congrFun h i
  exact_mod_cast hcast

/-- The simplex point set is a uniqueness set for polynomials of total degree `≤ d`. -/
theorem simplexPoints_uniqueness {n d : ℕ} (p q : MvPolynomial (Fin n) K)
    (hp : p.totalDegree ≤ d) (hq : q.totalDegree ≤ d)
    (h : ∀ t ∈ simplexPoints K n d, eval t p = eval t q) : p = q :=
  eq_of_eval_eq_on_simplex p q hp hq
    (fun a ha => h _ (mem_simplexPoints.mpr ⟨a, ha, rfl⟩))

/-- **Optimality of the simplex lattice.**  The simplex point set is a uniqueness set for
polynomials of total degree `≤ d`, and every uniqueness set has at least as many points:
it is a minimum-cardinality uniqueness set. -/
theorem simplexPoints_is_minimum_uniqueness_set (n d : ℕ) :
    (∀ p q : MvPolynomial (Fin n) K, p.totalDegree ≤ d → q.totalDegree ≤ d →
        (∀ t ∈ simplexPoints K n d, eval t p = eval t q) → p = q) ∧
      ∀ T : Finset (Fin n → K),
        (∀ p q : MvPolynomial (Fin n) K, p.totalDegree ≤ d → q.totalDegree ≤ d →
          (∀ t ∈ T, eval t p = eval t q) → p = q) →
        (simplexPoints K n d).card ≤ T.card := by
  refine ⟨fun p q hp hq h => simplexPoints_uniqueness p q hp hq h, fun T hT => ?_⟩
  rw [card_simplexPoints]
  exact uniqueness_set_card_ge T hT

end Optimal

/-! ## Consequence for the reflective calculus -/

namespace NExpr

variable {n : ℕ}

/-- **Simplex-lattice certificate.**  Two expressions of syntactic degree `≤ d` that agree
at the integer lattice points `a ∈ ℕⁿ` with `∑ aᵢ ≤ d` define the same function in every
commutative ring.  This replaces the `(d+1)^n` points of `NExpr.degree_exact` by the
`#(monomialsLE n d)` points of the simplex lattice, which is optimal. -/
theorem simplex_degree_exact {d : ℕ} (e₁ e₂ : NExpr n) (h₁ : e₁.deg ≤ d) (h₂ : e₂.deg ≤ d)
    (hsimp : ∀ a : Fin n → ℕ, ∑ i, a i ≤ d → e₁.eval (fun i => ((a i : ℕ) : ℤ))
      = e₂.eval (fun i => ((a i : ℕ) : ℤ)))
    (R : Type*) [CommRing R] (x : Fin n → R) : e₁.eval x = e₂.eval x := by
  refine eval_eq_of_toZ_eq e₁ e₂ ?_ x
  refine eq_of_eval_eq_on_simplex (K := ℤ) e₁.toZ e₂.toZ ((totalDegree_toZ_le e₁).trans h₁)
    ((totalDegree_toZ_le e₂).trans h₂) (fun a ha => ?_)
  rw [← eval_int, ← eval_int]
  exact hsimp a ha

/-- The degree-`3` instance: chart identities of degree `≤ 3` are decided by the simplex
lattice instead of the `4^n` box-grid points. -/
theorem simplex_degree_three_exact (e₁ e₂ : NExpr n) (h₁ : e₁.deg ≤ 3) (h₂ : e₂.deg ≤ 3)
    (hsimp : ∀ a : Fin n → ℕ, ∑ i, a i ≤ 3 → e₁.eval (fun i => ((a i : ℕ) : ℤ))
      = e₂.eval (fun i => ((a i : ℕ) : ℤ)))
    (R : Type*) [CommRing R] (x : Fin n → R) : e₁.eval x = e₂.eval x :=
  simplex_degree_exact e₁ e₂ h₁ h₂ hsimp R x

end NExpr

end ChartCalculus