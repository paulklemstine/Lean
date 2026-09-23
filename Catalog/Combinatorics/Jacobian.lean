/-
# The Picard group and the Jacobian of a graph

The divisor theory developed in the previous files is here packaged into the standard
group-theoretic objects: the group of principal divisors (the image of the Laplacian),
the Picard group `Pic G = Div(G) / Prin(G)`, and the *Jacobian* `Jac G`, the degree-zero
part of `Pic G`.  The `q`-reduced divisors of Dhar then provide a canonical system of
representatives, which turns the abstract quotient into a concrete finite object.

Main results:
* `TropicalRR.exists_unique_qreduced` : every divisor class contains a *unique* `q`-reduced
  divisor;
* `TropicalRR.jacEquivQReduced` : the Jacobian is in bijection with the set of `q`-reduced
  divisors of degree `0`;
* `TropicalRR.finite_jac` : the Jacobian of a connected graph is finite;
* `TropicalRR.card_jac_le_prod_degree` : `|Jac G| ≤ ∏_{v ≠ q} deg v` for every base vertex `q`;
* `TropicalRR.subsingleton_jac_of_isTree` and `TropicalRR.nontrivial_jac_of_genus_pos`,
  combining into `TropicalRR.jac_subsingleton_iff_isTree` : **the Jacobian of a connected
  graph is trivial if and only if the graph is a tree**.

The last theorem is a genuine consequence of the chip-firing Riemann–Roch machinery: the
"tree" direction uses `rank_eq_of_degD_large` (every degree-zero divisor on a genus-zero
graph wins), while the "positive genus" direction produces an explicit nontrivial class as
the difference of an acyclic-orientation divisor `ν_t` (rank `-1`) and the effective divisor
of the same degree `g - 1` concentrated at a vertex.
-/
import Combinatorics.TropicalRiemannRoch.Gonality

namespace TropicalRR

open Finset

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ### Principal divisors and the Picard group -/

/-- The Laplacian as an additive homomorphism `ℤ^V → Div(G)`. -/
def lapHom : (V → ℤ) →+ Divisor V := AddMonoidHom.mk' (lap G) (lap_add G)

omit [DecidableEq V] in
@[simp] lemma lapHom_apply (f : V → ℤ) : lapHom G f = lap G f := rfl

/-- The subgroup of principal divisors, i.e. the image of the Laplacian. -/
def principal : AddSubgroup (Divisor V) := (lapHom G).range

omit [DecidableEq V] in
lemma mem_principal_iff {D : Divisor V} : D ∈ principal G ↔ ∃ f : V → ℤ, lap G f = D :=
  Iff.rfl

omit [DecidableEq V] in
lemma linEquiv_iff_sub_mem_principal (D E : Divisor V) :
    LinEquiv G D E ↔ D - E ∈ principal G := by
  constructor
  · rintro ⟨f, rfl⟩
    exact ⟨f, by abel⟩
  · rintro ⟨f, hf⟩
    have hf' : lap G f = D - E := hf
    exact ⟨f, by rw [hf']; abel⟩

/-- The Picard group of a graph: divisors modulo chip-firing. -/
abbrev Pic := Divisor V ⧸ principal G

/-- The degree, as an additive homomorphism on divisors. -/
def degHom : Divisor V →+ ℤ where
  toFun := degD
  map_zero' := by simp [degD]
  map_add' := degD_add

omit [DecidableEq V] in
@[simp] lemma degHom_apply (D : Divisor V) : degHom D = degD D := rfl

/-- The degree descends to the Picard group. -/
def degPic : Pic G →+ ℤ :=
  QuotientAddGroup.lift (principal G) degHom (by
    rintro D ⟨f, rfl⟩
    simp [degD_lap G f])

omit [DecidableEq V] in
@[simp] lemma degPic_mk (D : Divisor V) :
    degPic G (QuotientAddGroup.mk D) = degD D := rfl

/-- The Jacobian of a graph: the group of degree-zero divisor classes. -/
def Jac : AddSubgroup (Pic G) := (degPic G).ker

omit [DecidableEq V] in
lemma mem_jac_iff (x : Pic G) : x ∈ Jac G ↔ degPic G x = 0 := Iff.rfl

/-! ### The canonical system of representatives -/

/-- **Every divisor class contains exactly one `q`-reduced divisor.** -/
theorem exists_unique_qreduced (hc : G.Connected) (D : Divisor V) (q : V) :
    ∃! E : Divisor V, QReduced G q E ∧ LinEquiv G D E := by
  obtain ⟨f, hf⟩ := exists_qreduced G hc D q
  refine ⟨D - lap G f, ⟨hf, ⟨f, rfl⟩⟩, ?_⟩
  rintro E ⟨hE, hDE⟩
  exact qreduced_unique G (hDE.symm G |>.trans G ⟨f, rfl⟩) hE hf

/-- In a `q`-reduced divisor, every vertex other than `q` carries fewer chips than its
degree: firing the single vertex `v` would already make it negative. -/
lemma QReduced.lt_degree {q : V} {D : Divisor V} (hD : QReduced G q D) {v : V} (hv : v ≠ q) :
    D v < (G.degree v : ℤ) := by
  obtain ⟨u, hu, hlt⟩ := hD.2 {v} ⟨v, Finset.mem_singleton_self v⟩ (by simpa using Ne.symm hv)
  rw [Finset.mem_singleton] at hu
  subst hu
  have hout : outdeg G {u} u = G.degree u := by
    rw [outdeg, Finset.sdiff_singleton_eq_erase,
      Finset.erase_eq_of_notMem (G.notMem_neighborFinset_self u),
      SimpleGraph.card_neighborFinset_eq_degree]
  rwa [hout] at hlt

/-- The `q`-reduced divisors of degree zero, a subtype of divisors. -/
def QRedZero (q : V) : Type _ := {D : Divisor V // QReduced G q D ∧ degD D = 0}

/-- The map sending a `q`-reduced divisor of degree zero to its class in the Jacobian. -/
def toJac (q : V) (D : QRedZero G q) : Jac G :=
  ⟨QuotientAddGroup.mk D.1, by simp [mem_jac_iff, D.2.2]⟩

lemma toJac_injective (q : V) : Function.Injective (toJac G q) := by
  rintro ⟨D, hD, hD0⟩ ⟨E, hE, hE0⟩ h
  have hmk : (QuotientAddGroup.mk D : Pic G) = QuotientAddGroup.mk E := congrArg Subtype.val h
  have hsub : D - E ∈ principal G := by
    rw [← QuotientAddGroup.eq_iff_sub_mem] at *
    exact hmk
  exact Subtype.ext (qreduced_unique G ((linEquiv_iff_sub_mem_principal G D E).2 hsub) hD hE)

lemma toJac_surjective (hc : G.Connected) (q : V) : Function.Surjective (toJac G q) := by
  rintro ⟨x, hx⟩
  obtain ⟨D, rfl⟩ := QuotientAddGroup.mk_surjective x
  obtain ⟨f, hf⟩ := exists_qreduced G hc D q
  have hdeg : degD D = 0 := by simpa [mem_jac_iff] using hx
  refine ⟨⟨D - lap G f, hf, by simp [hdeg]⟩, ?_⟩
  refine Subtype.ext ?_
  simp only [toJac]
  rw [QuotientAddGroup.eq_iff_sub_mem]
  refine ⟨-f, ?_⟩
  show lap G (-f) = D - lap G f - D
  rw [lap_neg]
  abel

/-- **The Jacobian is in bijection with the `q`-reduced divisors of degree zero**, for any
choice of base vertex `q`. -/
noncomputable def jacEquivQReduced (hc : G.Connected) (q : V) : QRedZero G q ≃ Jac G :=
  Equiv.ofBijective _ ⟨toJac_injective G q, toJac_surjective G hc q⟩

/-! ### Finiteness -/

/-- The coordinates of a `q`-reduced divisor of degree zero, away from `q`, viewed inside the
finite product `∏_{v ≠ q} Fin (deg v)`. -/
def qredCoords (q : V) (D : QRedZero G q) :
    ∀ v : (Finset.univ.erase q : Finset V), Fin (G.degree v.1) :=
  fun v => ⟨(D.1 v.1).toNat, by
    have hv : (v : V) ≠ q := (Finset.mem_erase.1 v.2).1
    have h1 : 0 ≤ D.1 v.1 := D.2.1.1 _ hv
    have h2 : D.1 v.1 < (G.degree v.1 : ℤ) := QReduced.lt_degree G D.2.1 hv
    omega⟩

lemma qredCoords_injective (q : V) : Function.Injective (qredCoords G q) := by
  rintro ⟨D, hD, hD0⟩ ⟨E, hE, hE0⟩ h
  have hoff : ∀ v : V, v ≠ q → D v = E v := by
    intro v hv
    have hmem : v ∈ Finset.univ.erase q := Finset.mem_erase.2 ⟨hv, Finset.mem_univ v⟩
    have := congrFun h ⟨v, hmem⟩
    have h1 : 0 ≤ D v := hD.1 _ hv
    have h2 : 0 ≤ E v := hE.1 _ hv
    have := congrArg Fin.val this
    simp only [qredCoords] at this
    omega
  have hq : D q = E q := by
    have hD1 : ∑ v ∈ Finset.univ.erase q, D v + D q = 0 := by
      rw [Finset.sum_erase_add _ _ (Finset.mem_univ q)]
      exact hD0
    have hE1 : ∑ v ∈ Finset.univ.erase q, E v + E q = 0 := by
      rw [Finset.sum_erase_add _ _ (Finset.mem_univ q)]
      exact hE0
    have hsum : ∑ v ∈ Finset.univ.erase q, D v = ∑ v ∈ Finset.univ.erase q, E v :=
      Finset.sum_congr rfl fun v hv => hoff v (Finset.mem_erase.1 hv).1
    omega
  refine Subtype.ext (funext fun v => ?_)
  by_cases hv : v = q
  · subst hv; exact hq
  · exact hoff v hv

instance instFiniteQRedZero (q : V) : Finite (QRedZero G q) :=
  Finite.of_injective _ (qredCoords_injective G q)

/-- **The Jacobian of a connected graph is finite.** -/
theorem finite_jac (hc : G.Connected) : Finite (Jac G) := by
  haveI : Nonempty V := hc.nonempty
  obtain ⟨q⟩ := ‹Nonempty V›
  exact Finite.of_equiv _ (jacEquivQReduced G hc q)

/-- **A quantitative form of the matrix–tree bound**: the number of degree-zero divisor
classes is at most `∏_{v ≠ q} deg v`, for any base vertex `q`. -/
theorem card_jac_le_prod_degree (hc : G.Connected) (q : V) :
    Nat.card (Jac G) ≤ ∏ v ∈ Finset.univ.erase q, G.degree v := by
  have h1 : Nat.card (Jac G) = Nat.card (QRedZero G q) :=
    (Nat.card_congr (jacEquivQReduced G hc q)).symm
  have h2 : Nat.card (QRedZero G q) ≤
      Nat.card (∀ v : (Finset.univ.erase q : Finset V), Fin (G.degree v.1)) :=
    Nat.card_le_card_of_injective _ (qredCoords_injective G q)
  have h3 : Nat.card (∀ v : (Finset.univ.erase q : Finset V), Fin (G.degree v.1))
      = ∏ v ∈ Finset.univ.erase q, G.degree v := by
    rw [Nat.card_eq_fintype_card, Fintype.card_pi]
    simp only [Fintype.card_fin]
    exact Finset.prod_attach (Finset.univ.erase q) (fun v => G.degree v)
  omega

/-! ### The Jacobian is trivial exactly for trees -/

/-- On a tree every degree-zero divisor is principal, so the Jacobian is trivial. -/
theorem subsingleton_jac_of_isTree (hc : G.Connected) (hT : G.IsTree) :
    Subsingleton (Jac G) := by
  haveI : Nonempty V := hc.nonempty
  have hg : genus G = 0 := (genus_eq_zero_iff_isTree G hc).2 hT
  have key : ∀ D : Divisor V, degD D = 0 → (QuotientAddGroup.mk D : Pic G) = 0 := by
    intro D hD
    have hrank : rank G D = degD D - genus G :=
      rank_eq_of_degD_large G hc (by omega)
    have hwin : Winnable G D := by
      rw [← rankGE_zero_iff]
      have : ((0 : ℕ) : ℤ) ≤ rank G D := by omega
      exact (rank_ge_iff G D 0).1 this
    obtain ⟨E, hDE, hEe⟩ := hwin
    have hdegE : degD E = 0 := by rw [hDE.degD_eq G, hD]
    have hE0 : E = 0 := eq_zero_of_effective_of_degD_zero hEe hdegE
    subst hE0
    have : D - 0 ∈ principal G := (linEquiv_iff_sub_mem_principal G D 0).1 hDE
    rw [sub_zero] at this
    exact (QuotientAddGroup.eq_zero_iff _).2 this
  refine ⟨?_⟩
  rintro ⟨x, hx⟩ ⟨y, hy⟩
  obtain ⟨D, rfl⟩ := QuotientAddGroup.mk_surjective x
  obtain ⟨E, rfl⟩ := QuotientAddGroup.mk_surjective y
  have hD : degD D = 0 := by simpa [mem_jac_iff] using hx
  have hE : degD E = 0 := by simpa [mem_jac_iff] using hy
  refine Subtype.ext ?_
  show (QuotientAddGroup.mk D : Pic G) = QuotientAddGroup.mk E
  rw [key D hD, key E hE]

/-- If the graph has positive genus, the divisor `ν_t - (g-1)·q` is a nonzero element of the
Jacobian: `ν_t` is non-winnable while the chip divisor is effective. -/
theorem nontrivial_jac_of_genus_pos (hc : G.Connected) (hg : 1 ≤ genus G) :
    Nontrivial (Jac G) := by
  haveI : Nonempty V := hc.nonempty
  obtain ⟨q⟩ := ‹Nonempty V›
  classical
  set e := Fintype.equivFin V with he
  set t : V → ℕ := fun v => (e v : ℕ) with ht
  have htinj : Function.Injective t := by
    intro a b hab
    have : (e a : ℕ) = (e b : ℕ) := hab
    exact e.injective (Fin.ext this)
  set D : Divisor V := nu G t - chip q (genus G - 1) with hD
  have hdeg : degD D = 0 := by
    rw [hD, degD_sub, degD_nu G t htinj, degD_chip]
    ring
  refine ⟨⟨0, ⟨QuotientAddGroup.mk D, by simp [mem_jac_iff, hdeg]⟩, ?_⟩⟩
  intro hcontra
  have h0 : (QuotientAddGroup.mk D : Pic G) = 0 := (congrArg Subtype.val hcontra).symm
  have hmem : D ∈ principal G := (QuotientAddGroup.eq_zero_iff _).1 h0
  have hlin : LinEquiv G (nu G t) (chip q (genus G - 1)) := by
    refine (linEquiv_iff_sub_mem_principal G _ _).2 ?_
    simpa [hD] using hmem
  exact nu_not_winnable G t
    (Winnable.of_linEquiv G hlin (Winnable.of_effective G (effective_chip (by omega))))

/-- **The Jacobian of a connected graph is trivial if and only if the graph is a tree.** -/
theorem jac_subsingleton_iff_isTree (hc : G.Connected) :
    Subsingleton (Jac G) ↔ G.IsTree := by
  constructor
  · intro hsub
    by_contra hT
    have hg : genus G ≠ 0 := fun h => hT ((genus_eq_zero_iff_isTree G hc).1 h)
    have hgpos : 1 ≤ genus G := by
      have := genus_nonneg G hc
      omega
    have := nontrivial_jac_of_genus_pos G hc hgpos
    exact (not_subsingleton_iff_nontrivial.2 this) hsub
  · exact subsingleton_jac_of_isTree G hc

/-- The Jacobian of a graph of positive genus has at least two elements. -/
theorem two_le_card_jac_of_genus_pos (hc : G.Connected) (hg : 1 ≤ genus G) :
    2 ≤ Nat.card (Jac G) := by
  haveI := finite_jac G hc
  haveI := nontrivial_jac_of_genus_pos G hc hg
  exact Finite.one_lt_card_iff_nontrivial.2 ‹Nontrivial (Jac G)›

/-- **The Jacobian has exactly one element precisely for trees.** -/
theorem card_jac_eq_one_iff_isTree (hc : G.Connected) :
    Nat.card (Jac G) = 1 ↔ G.IsTree := by
  haveI := finite_jac G hc
  constructor
  · intro h
    refine (jac_subsingleton_iff_isTree G hc).1 ?_
    by_contra hns
    have : Nontrivial (Jac G) := not_subsingleton_iff_nontrivial.1 hns
    have := Finite.one_lt_card_iff_nontrivial.2 this
    omega
  · intro hT
    haveI := subsingleton_jac_of_isTree G hc hT
    exact Nat.card_eq_one_iff_unique.2 ⟨‹Subsingleton (Jac G)›, ⟨⟨0, (Jac G).zero_mem⟩⟩⟩

/-! ### Shifting the degree, and the structure of the Picard group -/

omit [Fintype V] in
lemma chip_neg (q : V) (k : ℤ) : chip q (-k) = -chip q k := by
  funext v; by_cases h : v = q <;> simp [chip, h]

/-- Adding chips at the base vertex preserves `q`-reducedness: the defining conditions only
constrain the vertices different from `q`. -/
lemma qreduced_add_chip {q : V} {D : Divisor V} (hD : QReduced G q D) (k : ℤ) :
    QReduced G q (D + chip q k) := by
  have hval : ∀ v, v ≠ q → (D + chip q k) v = D v := by
    intro v hv; simp [chip, hv]
  refine ⟨fun v hv => by rw [hval v hv]; exact hD.1 v hv, ?_⟩
  intro S hS hq
  obtain ⟨v, hv, hlt⟩ := hD.2 S hS hq
  exact ⟨v, hv, by rw [hval v (fun h => hq (h ▸ hv))]; exact hlt⟩

/-- The `q`-reduced divisors of a fixed degree `d`. -/
def QRedDeg (q : V) (d : ℤ) : Type _ := {D : Divisor V // QReduced G q D ∧ degD D = d}

/-- Translating by `d` chips at `q` identifies the `q`-reduced divisors of degree `d` with
those of degree `0`. -/
def qredDegEquivZero (q : V) (d : ℤ) : QRedDeg G q d ≃ QRedZero G q where
  toFun D := ⟨D.1 + chip q (-d), qreduced_add_chip G D.2.1 (-d), by simp [D.2.2]⟩
  invFun D := ⟨D.1 + chip q d, qreduced_add_chip G D.2.1 d, by simp [D.2.2]⟩
  left_inv D := by
    refine Subtype.ext ?_
    show D.1 + chip q (-d) + chip q d = D.1
    rw [chip_neg]
    abel
  right_inv D := by
    refine Subtype.ext ?_
    show D.1 + chip q d + chip q (-d) = D.1
    rw [chip_neg]
    abel

/-- **The number of `q`-reduced divisors of degree `d` is `|Jac G|`, independently of `d`.**
These divisors are canonical representatives of the degree-`d` divisor classes. -/
theorem card_qredDeg (hc : G.Connected) (q : V) (d : ℤ) :
    Nat.card (QRedDeg G q d) = Nat.card (Jac G) :=
  Nat.card_congr ((qredDegEquivZero G q d).trans (jacEquivQReduced G hc q))

/-- **Structure of the Picard group**: choosing a base vertex `q` splits the degree map and
identifies `Pic G` with `ℤ × Jac G`.  Combined with `finite_jac`, this says that the Picard
group of a connected graph is `ℤ` extended by a finite group. -/
noncomputable def picEquivProdJac (q : V) : Pic G ≃+ ℤ × Jac G where
  toFun x := (degPic G x, ⟨x - degPic G x • (QuotientAddGroup.mk (chip q 1) : Pic G), by
    simp [mem_jac_iff, map_zsmul]⟩)
  invFun p := p.1 • (QuotientAddGroup.mk (chip q 1) : Pic G) + (p.2 : Pic G)
  left_inv x := by simp
  right_inv p := by
    have hp : degPic G ((p.2 : Pic G)) = 0 := p.2.2
    refine Prod.ext ?_ ?_
    · simp [map_zsmul, hp]
    · refine Subtype.ext ?_
      simp [map_zsmul, hp]
  map_add' x y := by
    refine Prod.ext (by simp) (Subtype.ext ?_)
    simp only [Prod.snd_add, AddSubgroup.coe_add, map_add]
    rw [add_zsmul]
    abel

end TropicalRR