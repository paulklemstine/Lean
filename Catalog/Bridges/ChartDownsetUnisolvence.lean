/-
# Downset (Newton-polytope) unisolvence: node sets adapted to the support

`Bridges.ChartSimplexUnisolvence` shows that the simplex lattice `{a : ∑ aᵢ ≤ d}` is a
minimum-cardinality uniqueness set for polynomials of *total degree* `≤ d`.  That bound is
optimal only for dense polynomials: a sparse polynomial whose exponent set sits inside a
small **downset** (a lower set `D ⊆ ℕⁿ` for the componentwise order — equivalently, the
lattice points of a Newton polytope closed under coordinate decrease) should be determined
by the far smaller node set `D` itself.

This file proves exactly that, and the converse:

* `ChartCalculus.downset_unisolvent` — over any characteristic-zero domain, a polynomial
  whose support lies in a lower set `D` and which vanishes at the lattice nodes of `D` is
  zero.  The proof is a single induction on the number of variables: after `finSuccEquiv`
  the leading coefficient in `x₀` is supported in the fiber of `D` over the top degree `N`,
  and above each such fiber point the whole column `0, …, N` of nodes lies in `D`, so a
  univariate polynomial of degree `≤ N` with `N+1` roots kills that leading coefficient.
* `ChartCalculus.downset_unisolvent_of_castInj` and
  `ChartCalculus.downset_unisolvent_of_lt_ringChar` — the same statement in positive
  characteristic, needing only that the coordinates occurring in `D` stay below the
  characteristic, together with `ChartCalculus.box_not_unisolvent_of_char_le`, which shows
  by an Artin–Schreier witness that this bound is exact.
* `ChartCalculus.exists_unique_downset_interpolant` — the converse half over a field:
  evaluation at the `#D` nodes is a *bijection* onto `K^D`, so downset interpolation always
  exists and is unique.  Since `#D` is the dimension of the space, the node set is of
  minimum cardinality (`ChartCalculus.downset_uniqueness_set_card_ge`).
* Corollaries: weighted-degree (quasi-homogeneous) unisolvence
  (`ChartCalculus.weighted_unisolvent`), which specialises to the simplex
  (`ChartCalculus.simplex_unisolvent_via_downset`) and to the per-variable box
  (`ChartCalculus.box_unisolvent_via_downset`).
* The reflective layer: a syntactic weighted degree `ChartCalculus.NExpr.wdeg` on the
  chart calculus, a decidable weighted certificate `ChartCalculus.NExpr.WeightedCert`
  proved sound *and* complete (`ChartCalculus.NExpr.weightedCert_iff_toZ_eq`), and a worked
  identity certified with `9` evaluations where the total-degree simplex needs `15` and the
  box grid `25`.
-/
import Bridges.ChartSimplexCertificates

open MvPolynomial

namespace ChartCalculus

/-! ## Lattice nodes -/

/-- The evaluation point attached to an exponent vector `a ∈ ℕⁿ`: its coordinates, cast
into the ring. -/
def latticeNode {K : Type*} [CommRing K] {n : ℕ} (a : Fin n →₀ ℕ) : Fin n → K :=
  fun i => ((a i : ℕ) : K)

section Nodes

variable {K : Type*} [CommRing K]

theorem cons_le_cons {n : ℕ} {j j' : ℕ} {m m' : Fin n →₀ ℕ} (hj : j' ≤ j) (hm : m' ≤ m) :
    Finsupp.cons j' m' ≤ Finsupp.cons j m := by
  rw [Finsupp.le_def]
  intro i
  refine Fin.cases ?_ ?_ i
  · simpa using hj
  · intro k
    simpa using (Finsupp.le_def.mp hm k)

theorem latticeNode_cons {n : ℕ} (j : ℕ) (m : Fin n →₀ ℕ) :
    (latticeNode (Finsupp.cons j m) : Fin (n + 1) → K)
      = Fin.cons ((j : ℕ) : K) (latticeNode m) := by
  funext i
  refine Fin.cases ?_ ?_ i <;> simp [latticeNode]

/-- Over a characteristic-zero ring distinct exponent vectors give distinct nodes. -/
theorem latticeNode_injective [CharZero K] {n : ℕ} :
    Function.Injective (latticeNode (K := K) (n := n)) := by
  intro a b hab
  ext i
  have := congrFun hab i
  simpa [latticeNode] using Nat.cast_injective (R := K) this

end Nodes

/-! ## The main unisolvence theorem -/

/-- **Downset unisolvence, below the characteristic.**  Let `D ⊆ ℕⁿ` be a lower set all of
whose exponent vectors have coordinates `≤ b`, over a domain in which the naturals
`0, …, b` have pairwise distinct images.  Then a polynomial supported in `D` vanishing at
every lattice node of `D` is zero. -/
theorem downset_unisolvent_of_castInj {K : Type*} [CommRing K] [IsDomain K] (b : ℕ)
    (hcast : ∀ i j : ℕ, i ≤ b → j ≤ b → (i : K) = (j : K) → i = j) :
    ∀ {n : ℕ} (D : Set (Fin n →₀ ℕ)), IsLowerSet D → (∀ a ∈ D, ∀ i, a i ≤ b) →
      ∀ p : MvPolynomial (Fin n) K, ↑p.support ⊆ D →
        (∀ a ∈ D, eval (latticeNode a) p = 0) → p = 0 := by
  intro n
  induction n with
  | zero =>
      intro D _ _ p hsupp hvan
      by_contra hp
      obtain ⟨a, ha⟩ := MvPolynomial.support_nonempty.mpr hp
      have hv := hvan a (hsupp ha)
      have hdeg : p.totalDegree = 0 := totalDegree_fin_zero p
      rw [MvPolynomial.totalDegree_eq_zero_iff_eq_C] at hdeg
      rw [hdeg] at hv hp
      simp only [eval_C] at hv
      exact hp (by simp [hv])
  | succ n ih =>
      intro D hD hDb p hsupp hvan
      by_contra hp
      set P := finSuccEquiv K n p with hP
      have hPne : P ≠ 0 := by simpa [hP] using hp
      set N := P.natDegree with hN
      set q := P.coeff N with hq
      have hqne : q ≠ 0 := Polynomial.leadingCoeff_ne_zero.mpr hPne
      -- the fiber of `D` over the top `x₀`-degree
      set E : Set (Fin n →₀ ℕ) := {m | Finsupp.cons N m ∈ D} with hE
      have hElower : IsLowerSet E := fun m m' hle hm => hD (cons_le_cons (le_refl N) hle) hm
      have hqsupp : (↑q.support : Set (Fin n →₀ ℕ)) ⊆ E := by
        intro m hm
        simp only [Finset.mem_coe, MvPolynomial.mem_support_iff] at hm
        rw [hq, MvPolynomial.finSuccEquiv_coeff_coeff] at hm
        exact hsupp (by simpa [MvPolynomial.mem_support_iff] using hm)
      have hEb : ∀ m ∈ E, ∀ i, m i ≤ b := by
        intro m hm i
        simpa using hDb _ hm i.succ
      -- the top degree in `x₀` is at most `b`
      have hNb : N ≤ b := by
        obtain ⟨m, hm⟩ := MvPolynomial.support_nonempty.mpr hqne
        simpa using hDb _ (hqsupp hm) 0
      have hqvan : ∀ m ∈ E, eval (latticeNode m) q = 0 := by
        intro m hm
        set u := P.map (eval (latticeNode m)) with hu
        have hu0 : u = 0 := by
          refine Polynomial.eq_zero_of_natDegree_lt_card_of_eval_eq_zero u
            (f := fun j : Fin (N + 1) => ((j : ℕ) : K)) ?_ ?_ ?_
          · intro c c' hcc
            simp only at hcc
            exact Fin.ext (hcast _ _ (le_trans (Nat.lt_succ_iff.mp c.isLt) hNb)
              (le_trans (Nat.lt_succ_iff.mp c'.isLt) hNb) hcc)
          · intro j
            have hmem : Finsupp.cons (j : ℕ) m ∈ D :=
              hD (cons_le_cons (Nat.lt_succ_iff.mp j.isLt) (le_refl m)) hm
            have hv := hvan _ hmem
            rw [latticeNode_cons, MvPolynomial.eval_eq_eval_mv_eval'] at hv
            simpa [hu, hP] using hv
          · have hle : u.natDegree ≤ N := by
              simpa [hu, hN] using Polynomial.natDegree_map_le
                (f := (eval (latticeNode m) : MvPolynomial (Fin n) K →+* K)) (p := P)
            rw [Fintype.card_fin]
            omega
        have hcoef := congrArg (fun r : Polynomial K => r.coeff N) hu0
        simpa [hu, Polynomial.coeff_map, hq] using hcoef
      exact hqne (ih E hElower hEb q hqsupp hqvan)

/-- **Downset unisolvence.**  Over a characteristic-zero domain, a polynomial whose support
is contained in a lower set `D ⊆ ℕⁿ` and which vanishes at every lattice node of `D` is the
zero polynomial. -/
theorem downset_unisolvent {K : Type*} [CommRing K] [IsDomain K] [CharZero K] {n : ℕ}
    (D : Set (Fin n →₀ ℕ)) (hD : IsLowerSet D) (p : MvPolynomial (Fin n) K)
    (hsupp : ↑p.support ⊆ D) (hvan : ∀ a ∈ D, eval (latticeNode a) p = 0) : p = 0 := by
  -- restrict `D` to the exponent box that already contains the support of `p`
  refine downset_unisolvent_of_castInj p.totalDegree
    (fun i j _ _ h => Nat.cast_injective h)
    {a : Fin n →₀ ℕ | a ∈ D ∧ ∀ i, a i ≤ p.totalDegree} ?_ (fun a ha i => ha.2 i) p ?_
    (fun a ha => hvan a ha.1)
  · exact fun x y hle hx =>
      ⟨hD hle hx.1, fun i => le_trans (Finsupp.le_def.mp hle i) (hx.2 i)⟩
  · intro a ha
    exact ⟨hsupp ha, fun i => le_trans (coord_le_sum a i)
      (MvPolynomial.le_totalDegree (by simpa using ha))⟩

/-- **Downset unisolvence in positive characteristic.**  If every exponent occurring in `D`
has coordinates `< ringChar K`, the conclusion survives without any characteristic-zero
assumption. -/
theorem downset_unisolvent_of_lt_ringChar {K : Type*} [CommRing K] [IsDomain K] {n b : ℕ}
    (hb : b < ringChar K) (D : Set (Fin n →₀ ℕ)) (hD : IsLowerSet D)
    (hDb : ∀ a ∈ D, ∀ i, a i ≤ b) (p : MvPolynomial (Fin n) K) (hsupp : ↑p.support ⊆ D)
    (hvan : ∀ a ∈ D, eval (latticeNode a) p = 0) : p = 0 := by
  refine downset_unisolvent_of_castInj b (fun i j hi hj hij => ?_) D hD hDb p hsupp hvan
  by_contra hne
  rcases Nat.lt_or_ge i j with h | h
  · have hz : ((j - i : ℕ) : K) = 0 := by
      rw [Nat.cast_sub (le_of_lt h), hij, sub_self]
    have hdvd := (ringChar.spec K (j - i)).mp hz
    have hle := Nat.le_of_dvd (by omega) hdvd
    omega
  · have hji : j < i := by omega
    have hz : ((i - j : ℕ) : K) = 0 := by
      rw [Nat.cast_sub (le_of_lt hji), hij, sub_self]
    have hdvd := (ringChar.spec K (i - j)).mp hz
    have hle := Nat.le_of_dvd (by omega) hdvd
    omega

/-- **The characteristic bound is exact.**  In prime characteristic `c`, as soon as the
exponent box allows a coordinate `≥ c` the lattice nodes no longer determine the
polynomials supported in it: the Artin–Schreier witness `x₀^c - x₀` is nonzero, supported
in the box, and vanishes at every node.  With `downset_unisolvent_of_lt_ringChar` this makes
`b < c` an exact criterion. -/
theorem box_not_unisolvent_of_char_le {K : Type*} [CommRing K] [IsDomain K] {c : ℕ}
    [CharP K c] (hc : c.Prime) {n b : ℕ} (hn : 0 < n) (hb : c ≤ b) :
    ∃ q : MvPolynomial (Fin n) K, q ≠ 0 ∧ (∀ a ∈ q.support, ∀ i, a i ≤ b) ∧
      ∀ a : Fin n →₀ ℕ, (∀ i, a i ≤ b) → eval (latticeNode a) q = 0 := by
  haveI : Fact c.Prime := ⟨hc⟩
  haveI : ExpChar K c := ExpChar.prime hc
  set i₀ : Fin n := ⟨0, hn⟩ with hi₀
  have hdeg : (X i₀ ^ c - X i₀ : MvPolynomial (Fin n) K).totalDegree ≤ c := by
    refine (MvPolynomial.totalDegree_sub _ _).trans (max_le ?_ ?_)
    · refine (MvPolynomial.totalDegree_pow _ _).trans ?_
      simp [MvPolynomial.totalDegree_X]
    · simp only [MvPolynomial.totalDegree_X]
      have := hc.two_le
      omega
  refine ⟨X i₀ ^ c - X i₀, ?_, ?_, ?_⟩
  · intro h
    have h2 := hc.two_le
    have hcoe := congrArg (MvPolynomial.coeff (Finsupp.single i₀ c)) h
    rw [MvPolynomial.coeff_sub, MvPolynomial.coeff_X_pow, MvPolynomial.coeff_X',
      MvPolynomial.coeff_zero, if_pos rfl] at hcoe
    rw [if_neg] at hcoe
    · simp at hcoe
    · intro hEq
      have hval := congrArg (fun f => f i₀) hEq
      simp at hval
      omega
  · intro a ha i
    exact le_trans (le_trans (coord_le_sum a i)
      (le_trans (MvPolynomial.le_totalDegree ha) hdeg)) hb
  · intro a _
    have hfrob : (((a i₀ : ℕ) : K)) ^ c = ((a i₀ : ℕ) : K) := by
      have hmap := map_natCast (frobenius K c) (a i₀)
      rwa [frobenius_def] at hmap
    simp only [map_sub, MvPolynomial.eval_pow, MvPolynomial.eval_X, latticeNode]
    rw [hfrob, sub_self]

/-- Two polynomials supported in a lower set `D` that agree at the lattice nodes of `D` are
equal. -/
theorem eq_of_eval_eq_on_downset {K : Type*} [CommRing K] [IsDomain K] [CharZero K] {n : ℕ}
    (D : Set (Fin n →₀ ℕ)) (hD : IsLowerSet D) (p q : MvPolynomial (Fin n) K)
    (hp : ↑p.support ⊆ D) (hq : ↑q.support ⊆ D)
    (hval : ∀ a ∈ D, eval (latticeNode a) p = eval (latticeNode a) q) : p = q := by
  have hsub : ↑(p - q).support ⊆ D := by
    intro a ha
    have := MvPolynomial.support_sub (Fin n) p q (by simpa using ha)
    rcases Finset.mem_union.mp this with h | h
    · exact hp h
    · exact hq h
  have hzero := downset_unisolvent D hD (p - q) hsub (fun a ha => by
    simp [sub_eq_zero.mpr (hval a ha)])
  exact sub_eq_zero.mp hzero

/-! ## Weighted-degree downsets -/

section Weighted

/-- The weighted degree `∑ wᵢ aᵢ` of an exponent vector. -/
def wsum {n : ℕ} (w : Fin n → ℕ) (a : Fin n →₀ ℕ) : ℕ := ∑ i, w i * a i

@[simp] theorem wsum_zero {n : ℕ} (w : Fin n → ℕ) : wsum w 0 = 0 := by simp [wsum]

theorem wsum_add {n : ℕ} (w : Fin n → ℕ) (a b : Fin n →₀ ℕ) :
    wsum w (a + b) = wsum w a + wsum w b := by
  simp [wsum, Nat.mul_add, Finset.sum_add_distrib]

theorem wsum_mono {n : ℕ} (w : Fin n → ℕ) {a b : Fin n →₀ ℕ} (h : a ≤ b) :
    wsum w a ≤ wsum w b :=
  Finset.sum_le_sum (fun i _ => Nat.mul_le_mul_left _ (Finsupp.le_def.mp h i))

/-- Sublevel sets of a weighted degree are downsets: this is the source of all the concrete
node systems below. -/
theorem isLowerSet_wsumLE {n : ℕ} (w : Fin n → ℕ) (d : ℕ) :
    IsLowerSet {a : Fin n →₀ ℕ | wsum w a ≤ d} :=
  fun _ _ hle ha => le_trans (wsum_mono w hle) ha

theorem wsum_one {n : ℕ} (a : Fin n →₀ ℕ) : wsum (fun _ => 1) a = a.sum fun _ e => e := by
  rw [Finsupp.sum_fintype _ _ (fun _ => rfl)]
  simp [wsum]

theorem wsum_single {n : ℕ} (w : Fin n → ℕ) (i : Fin n) :
    wsum w (Finsupp.single i 1) = w i := by
  rw [wsum, Finset.sum_eq_single i]
  · simp
  · intro j _ hj; simp [Ne.symm hj]
  · intro h; exact absurd (Finset.mem_univ i) h

variable {K : Type*} [CommRing K] [IsDomain K] [CharZero K]

/-- **Quasi-homogeneous unisolvence.**  A polynomial all of whose exponents have weighted
degree `≤ d` is determined by its values on the weighted simplex `{a : ∑ wᵢaᵢ ≤ d}`. -/
theorem weighted_unisolvent {n : ℕ} (w : Fin n → ℕ) (d : ℕ) (p : MvPolynomial (Fin n) K)
    (hp : ∀ a ∈ p.support, wsum w a ≤ d)
    (hvan : ∀ a : Fin n →₀ ℕ, wsum w a ≤ d → eval (latticeNode a) p = 0) : p = 0 :=
  downset_unisolvent _ (isLowerSet_wsumLE w d) p (fun a ha => hp a ha) (fun a ha => hvan a ha)

/-- The simplex-lattice unisolvence theorem, recovered from the downset theorem by taking
all weights equal to `1`. -/
theorem simplex_unisolvent_via_downset {n d : ℕ} (p : MvPolynomial (Fin n) K)
    (hdeg : p.totalDegree ≤ d)
    (hvan : ∀ a : Fin n →₀ ℕ, (a.sum fun _ e => e) ≤ d → eval (latticeNode a) p = 0) :
    p = 0 := by
  refine weighted_unisolvent (fun _ => 1) d p (fun a ha => ?_) (fun a ha => ?_)
  · rw [wsum_one]; exact le_trans (MvPolynomial.le_totalDegree ha) hdeg
  · exact hvan a (by rwa [wsum_one] at ha)

/-- The per-variable (box) unisolvence theorem: the exponent box `{a : aᵢ ≤ bᵢ}` is a
downset, so bounded per-variable degrees are decided by the `∏(bᵢ+1)` box nodes. -/
theorem box_unisolvent_via_downset {n : ℕ} (b : Fin n → ℕ) (p : MvPolynomial (Fin n) K)
    (hdeg : ∀ i, degreeOf i p ≤ b i)
    (hvan : ∀ a : Fin n →₀ ℕ, (∀ i, a i ≤ b i) → eval (latticeNode a) p = 0) : p = 0 := by
  refine downset_unisolvent {a : Fin n →₀ ℕ | ∀ i, a i ≤ b i} ?_ p ?_ hvan
  · exact fun a a' hle ha i => le_trans (Finsupp.le_def.mp hle i) (ha i)
  · intro a ha i
    exact le_trans (MvPolynomial.monomial_le_degreeOf i (by simpa using ha)) (hdeg i)

/-- **Downsets are strictly more general than weighted-degree bounds.**  The downset
`{(a,0) : a ≤ 2} ∪ {(0,b) : b ≤ 2}` in `ℕ²` is contained in no weighted sublevel set that
avoids the exponent `(1,1)`: every weighted simplex containing it also contains `(1,1)`.
So the node systems produced by `downset_unisolvent` are strictly finer than the
quasi-homogeneous ones. -/
theorem exists_downset_not_weighted_sublevel :
    ∃ D : Set (Fin 2 →₀ ℕ), IsLowerSet D ∧ ∃ a₀ : Fin 2 →₀ ℕ, a₀ ∉ D ∧
      ∀ (w : Fin 2 → ℕ) (d : ℕ), D ⊆ {a | wsum w a ≤ d} → wsum w a₀ ≤ d := by
  classical
  refine ⟨{a : Fin 2 →₀ ℕ | (a 0 ≤ 2 ∧ a 1 = 0) ∨ (a 0 = 0 ∧ a 1 ≤ 2)}, ?_,
    Finsupp.single 0 1 + Finsupp.single 1 1, ?_, ?_⟩
  · intro a b hle ha
    have h0 := Finsupp.le_def.mp hle 0
    have h1 := Finsupp.le_def.mp hle 1
    rcases ha with ⟨ha0, ha1⟩ | ⟨ha0, ha1⟩
    · exact Or.inl ⟨by omega, by omega⟩
    · exact Or.inr ⟨by omega, by omega⟩
  · intro hmem
    have e0 : (Finsupp.single (0 : Fin 2) 1 + Finsupp.single (1 : Fin 2) 1 : Fin 2 →₀ ℕ) 0
        = 1 := by simp
    have e1 : (Finsupp.single (0 : Fin 2) 1 + Finsupp.single (1 : Fin 2) 1 : Fin 2 →₀ ℕ) 1
        = 1 := by simp
    rcases hmem with ⟨h, h'⟩ | ⟨h, h'⟩ <;> omega
  · intro w d hsub
    have hx : (Finsupp.single (0 : Fin 2) 2 : Fin 2 →₀ ℕ) ∈
        {a : Fin 2 →₀ ℕ | (a 0 ≤ 2 ∧ a 1 = 0) ∨ (a 0 = 0 ∧ a 1 ≤ 2)} := by
      left; constructor <;> simp
    have hy : (Finsupp.single (1 : Fin 2) 2 : Fin 2 →₀ ℕ) ∈
        {a : Fin 2 →₀ ℕ | (a 0 ≤ 2 ∧ a 1 = 0) ∨ (a 0 = 0 ∧ a 1 ≤ 2)} := by
      right; constructor <;> simp
    have hx' : wsum w (Finsupp.single (0 : Fin 2) 2) ≤ d := hsub hx
    have hy' : wsum w (Finsupp.single (1 : Fin 2) 2) ≤ d := hsub hy
    rw [wsum, Fin.sum_univ_two] at hx' hy' ⊢
    simp only [Finsupp.single_eq_same, Finsupp.add_apply] at *
    simp only [Finsupp.single_eq_of_ne (by decide : (0 : Fin 2) ≠ 1),
      Finsupp.single_eq_of_ne (by decide : (1 : Fin 2) ≠ 0)] at *
    omega

end Weighted

/-! ## Interpolation, and optimality of the node set -/

section Interpolation

variable {K : Type*} [Field K]

instance instFiniteDimensionalRestrictSupport {n : ℕ} (D : Finset (Fin n →₀ ℕ)) :
    FiniteDimensional K (MvPolynomial.restrictSupport K (↑D : Set (Fin n →₀ ℕ))) :=
  Module.Basis.finiteDimensional_of_finite
    (MvPolynomial.basisRestrictSupport K (↑D : Set (Fin n →₀ ℕ)))

/-- The space of polynomials supported in `D` has dimension `#D`. -/
theorem finrank_restrictSupport {n : ℕ} (D : Finset (Fin n →₀ ℕ)) :
    Module.finrank K (MvPolynomial.restrictSupport K (↑D : Set (Fin n →₀ ℕ))) = D.card := by
  rw [Module.finrank_eq_card_basis
    (MvPolynomial.basisRestrictSupport K (↑D : Set (Fin n →₀ ℕ)))]
  simp

/-- Evaluation of the polynomials supported in `D` at a finite set of points. -/
noncomputable def suppEvalMap (K : Type*) [Field K] {n : ℕ} (D : Finset (Fin n →₀ ℕ))
    (T : Finset (Fin n → K)) :
    MvPolynomial.restrictSupport K (↑D : Set (Fin n →₀ ℕ)) →ₗ[K] (T → K) where
  toFun p := fun t => eval (t : Fin n → K) (p : MvPolynomial (Fin n) K)
  map_add' p q := by funext t; simp
  map_smul' c p := by funext t; simp

/-- **Dimension obstruction for a prescribed support.**  Fewer test points than monomials
means some nonzero polynomial supported in `D` vanishes on all of them. -/
theorem exists_nonzero_vanishing_of_card_lt_card {n : ℕ} (D : Finset (Fin n →₀ ℕ))
    (T : Finset (Fin n → K)) (hlt : T.card < D.card) :
    ∃ p : MvPolynomial (Fin n) K, p ≠ 0 ∧ ↑p.support ⊆ (↑D : Set (Fin n →₀ ℕ)) ∧
      ∀ t ∈ T, eval t p = 0 := by
  have hnotinj : ¬ Function.Injective (suppEvalMap K D T) := by
    intro hinj
    have hrank := LinearMap.finrank_le_finrank_of_injective (f := suppEvalMap K D T) hinj
    rw [finrank_restrictSupport] at hrank
    simp only [Module.finrank_pi, Fintype.card_coe] at hrank
    omega
  obtain ⟨p, hpmem, hp0⟩ := Submodule.exists_mem_ne_zero_of_ne_bot
    (fun h => hnotinj (LinearMap.ker_eq_bot.mp h))
  refine ⟨(p : MvPolynomial (Fin n) K), fun h => hp0 (Subtype.ext h),
    (MvPolynomial.mem_restrictSupport_iff K).mp p.2, fun t ht => ?_⟩
  have hker : suppEvalMap K D T p = 0 := hpmem
  have := congrFun hker ⟨t, ht⟩
  simpa [suppEvalMap] using this

/-- **Lower bound for uniqueness sets of a prescribed support.** -/
theorem downset_uniqueness_set_card_ge {n : ℕ} (D : Finset (Fin n →₀ ℕ))
    (T : Finset (Fin n → K))
    (hU : ∀ p q : MvPolynomial (Fin n) K, ↑p.support ⊆ (↑D : Set (Fin n →₀ ℕ)) →
      ↑q.support ⊆ (↑D : Set (Fin n →₀ ℕ)) → (∀ t ∈ T, eval t p = eval t q) → p = q) :
    D.card ≤ T.card := by
  by_contra hlt
  push_neg at hlt
  obtain ⟨p, hp0, hps, hpv⟩ := exists_nonzero_vanishing_of_card_lt_card D T hlt
  exact hp0 (hU p 0 hps (by simp) (fun t ht => by simpa using hpv t ht))

/-- The lattice nodes of a finite exponent set. -/
noncomputable def downsetNodes (K : Type*) [Field K] [CharZero K] {n : ℕ}
    (D : Finset (Fin n →₀ ℕ)) : Finset (Fin n → K) :=
  D.map ⟨latticeNode, latticeNode_injective⟩

theorem mem_downsetNodes [CharZero K] {n : ℕ} {D : Finset (Fin n →₀ ℕ)} {a : Fin n →₀ ℕ}
    (ha : a ∈ D) : (latticeNode a : Fin n → K) ∈ downsetNodes K D :=
  Finset.mem_map_of_mem _ ha

theorem card_downsetNodes [CharZero K] {n : ℕ} (D : Finset (Fin n →₀ ℕ)) :
    (downsetNodes K D).card = D.card :=
  Finset.card_map _

/-- **The lattice nodes of a downset form a minimum-cardinality uniqueness set** for the
polynomials supported in that downset: they determine such polynomials, they number exactly
`#D`, and no set of test points with fewer than `#D` elements can determine them. -/
theorem downsetNodes_is_minimum_uniqueness_set [CharZero K] {n : ℕ} (D : Finset (Fin n →₀ ℕ))
    (hD : IsLowerSet (↑D : Set (Fin n →₀ ℕ))) :
    (∀ p q : MvPolynomial (Fin n) K, ↑p.support ⊆ (↑D : Set (Fin n →₀ ℕ)) →
        ↑q.support ⊆ (↑D : Set (Fin n →₀ ℕ)) →
        (∀ t ∈ downsetNodes K D, eval t p = eval t q) → p = q) ∧
      (downsetNodes K D).card = D.card ∧
      ∀ T : Finset (Fin n → K),
        (∀ p q : MvPolynomial (Fin n) K, ↑p.support ⊆ (↑D : Set (Fin n →₀ ℕ)) →
          ↑q.support ⊆ (↑D : Set (Fin n →₀ ℕ)) → (∀ t ∈ T, eval t p = eval t q) → p = q) →
        D.card ≤ T.card := by
  refine ⟨fun p q hp hq hval => eq_of_eval_eq_on_downset _ hD p q hp hq (fun a ha => ?_),
    card_downsetNodes D, fun T hT => downset_uniqueness_set_card_ge D T hT⟩
  exact hval _ (mem_downsetNodes (by simpa using ha))

/-- Evaluation of the polynomials supported in `D` at the nodes of `D` itself. -/
noncomputable def downsetEvalMap (K : Type*) [Field K] {n : ℕ} (D : Finset (Fin n →₀ ℕ)) :
    MvPolynomial.restrictSupport K (↑D : Set (Fin n →₀ ℕ)) →ₗ[K] (D → K) where
  toFun p := fun a => eval (latticeNode (a : Fin n →₀ ℕ)) (p : MvPolynomial (Fin n) K)
  map_add' p q := by funext a; simp
  map_smul' c p := by funext a; simp

theorem downsetEvalMap_injective [CharZero K] {n : ℕ} (D : Finset (Fin n →₀ ℕ))
    (hD : IsLowerSet (↑D : Set (Fin n →₀ ℕ))) :
    Function.Injective (downsetEvalMap K D) := by
  rw [injective_iff_map_eq_zero]
  intro p hp
  refine Subtype.ext (downset_unisolvent (↑D : Set (Fin n →₀ ℕ)) hD _
    ((MvPolynomial.mem_restrictSupport_iff K).mp p.2) (fun a ha => congrFun hp ⟨a, ha⟩))

/-- **Downset interpolation exists and is unique.**  Over a characteristic-zero field, for
every datum prescribed at the `#D` lattice nodes of a finite downset `D` there is exactly
one polynomial supported in `D` realising it: evaluation is a linear isomorphism. -/
theorem exists_unique_downset_interpolant [CharZero K] {n : ℕ} (D : Finset (Fin n →₀ ℕ))
    (hD : IsLowerSet (↑D : Set (Fin n →₀ ℕ))) (f : D → K) :
    ∃! p : MvPolynomial (Fin n) K, ↑p.support ⊆ (↑D : Set (Fin n →₀ ℕ)) ∧
      ∀ a : D, eval (latticeNode (a : Fin n →₀ ℕ)) p = f a := by
  have hcard : Module.finrank K (MvPolynomial.restrictSupport K (↑D : Set (Fin n →₀ ℕ)))
      = Module.finrank K (D → K) := by
    rw [finrank_restrictSupport, Module.finrank_fintype_fun_eq_card]
    simp
  obtain ⟨p, hp⟩ := (LinearMap.injective_iff_surjective_of_finrank_eq_finrank hcard).mp
    (downsetEvalMap_injective D hD) f
  refine ⟨(p : MvPolynomial (Fin n) K), ⟨(MvPolynomial.mem_restrictSupport_iff K).mp p.2,
    fun a => congrFun hp a⟩, ?_⟩
  rintro q ⟨hq1, hq2⟩
  have hqmem : q ∈ MvPolynomial.restrictSupport K (↑D : Set (Fin n →₀ ℕ)) :=
    (MvPolynomial.mem_restrictSupport_iff K).mpr hq1
  have hEq : (⟨q, hqmem⟩ : MvPolynomial.restrictSupport K (↑D : Set (Fin n →₀ ℕ))) = p := by
    refine downsetEvalMap_injective D hD ?_
    funext a
    simpa [downsetEvalMap] using (hq2 a).trans (congrFun hp a).symm
  exact congrArg Subtype.val hEq

end Interpolation

end ChartCalculus