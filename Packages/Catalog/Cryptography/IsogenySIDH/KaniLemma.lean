/-
# Kani's lemma for SIDH isogeny diamonds

This file formalizes the algebraic core of *Kani's lemma*, the statement that
turns an "isogeny diamond"

```
        φ
   E₁ ------> E₂
   |          |
 ψ |          | ψ'
   v    φ'    v
   E₃ ------> E₄
```

with `deg φ = deg φ' = a`, `deg ψ = deg ψ' = b` and `ψ' ∘ φ = φ' ∘ ψ`, into a
single isogeny

`F = ( φ    ψ'^ )  :  E₁ × E₄ → E₂ × E₃`
`    (-ψ    φ'^ )`

of degree `N² = (a+b)²` between abelian surfaces, whose kernel is the graph
`{ (φ^ Q, ψ' Q) : Q ∈ E₂[N] }`.

Kani's lemma is exactly the engine of the Castryck–Decru–Maino–Martindale
attack on SIDH: the public torsion images of an SIDH key exchange determine the
subgroup `{ (φ^ Q, ψ' Q) }`, hence the isogeny `F` of *smooth* degree `N²`,
which can be computed and which exposes the secret isogeny `φ`.

## Formalization choices

We work with an abstract, self-contained model of the situation.  Curves are
modelled by their groups of geometric points (arbitrary additive commutative
groups), isogenies by group homomorphisms, and the dual isogenies are supplied
as data satisfying the two defining relations `φ^ ∘ φ = [deg φ]` and
`φ ∘ φ^ = [deg φ]`.  Surjectivity of an isogeny over an algebraically closed
field is recorded as a hypothesis for the three maps where it is needed.

Everything else - in particular the two "dual square" identities
`φ'^ ∘ ψ' = ψ ∘ φ^` and `φ^ ∘ ψ'^ = ψ^ ∘ φ'^` - is *derived*.

## Main results

* `SIDH.Diamond.kaniDual_kani`  : `F^ ∘ F = [N]`
* `SIDH.Diamond.kani_kaniDual`  : `F ∘ F^ = [N]`
* `SIDH.Diamond.kani_graph`     : the graph of `E₂[N]` lies in `ker F`
* `SIDH.Diamond.mem_ker_kani_iff` : `ker F` *equals* that graph (Kani's lemma)
* `SIDH.Diamond.ker_kani_eq_map` : subgroup form of the same statement
* `SIDH.Diamond.graphMap_injective` : the graph parametrisation is injective
* `SIDH.Diamond.kani_ker_inter_left/right` : `ker F` meets neither factor
* `SIDH.Diamond.kerEquivTorsion` : `ker F ≃+ E₂[N]`, and
  `SIDH.Diamond.card_ker_kani` : `#ker F = N²` once `#E₂[N] = N²`
* `SIDH.Diamond.exists_unique_partner_left/right`,
  `SIDH.Diamond.glueTorsion_bijective` : `ker F` is the graph of an isomorphism
  `E₁[N] ≃ E₄[N]`, explicitly `x ↦ u • ψ'(φ x)` with `a u ≡ 1 (mod N)`
* `SIDH.Diamond.smul_glueMap` : the secret action `ψ' ∘ φ` on the `N`-torsion is
  recovered from `ker F`, which is the structural content of the attack
* `SIDH.Diamond.cmDiamond` : an explicit diamond of degrees `5` and `2` coming
  from complex multiplication by `ℤ[i]`, so the theory is non-vacuous
* `SIDH.Diamond.card_nTorsion_QZ` : `#(ℚ/ℤ)[n] = n`, proved from the exact
  sequence `0 → nℤ → ℤ → (ℚ/ℤ)[n] → 0` given by `k ↦ k/n`
* `SIDH.Diamond.cmDiamond_card_ker` : the Kani isogeny of the concrete diamond
  has kernel of order `N² = 49`, the predicted degree
* `SIDH.Diamond.gaussEnd_injective` : the complex multiplication action of
  `ℤ[i]` on the torsion group `(ℚ/ℤ)²` is faithful
-/
import Mathlib

namespace Cryptography.SIDH

open Function

/-- An **isogeny diamond**: a commutative square of isogenies
`ψ' ∘ φ = φ' ∘ ψ` with `deg φ = deg φ' = a` and `deg ψ = deg ψ' = b`,
together with the four dual isogenies.

Curves are modelled by their groups of points and isogenies by group
homomorphisms; the degree relations `φ^ φ = [a] = φ φ^` are the defining
property of the dual isogeny. -/
structure Diamond (E₁ E₂ E₃ E₄ : Type*) [AddCommGroup E₁] [AddCommGroup E₂]
    [AddCommGroup E₃] [AddCommGroup E₄] where
  /-- The degree of the horizontal isogenies `φ`, `φ'`. -/
  a : ℕ
  /-- The degree of the vertical isogenies `ψ`, `ψ'`. -/
  b : ℕ
  /-- The secret horizontal isogeny `E₁ → E₂`. -/
  phi : E₁ →+ E₂
  /-- The vertical isogeny `E₁ → E₃`. -/
  psi : E₁ →+ E₃
  /-- The pushforward of `φ` along `ψ`. -/
  phi' : E₃ →+ E₄
  /-- The pushforward of `ψ` along `φ`. -/
  psi' : E₂ →+ E₄
  /-- The dual of `φ`. -/
  phiHat : E₂ →+ E₁
  /-- The dual of `ψ`. -/
  psiHat : E₃ →+ E₁
  /-- The dual of `φ'`. -/
  phi'Hat : E₄ →+ E₃
  /-- The dual of `ψ'`. -/
  psi'Hat : E₄ →+ E₂
  phiHat_phi : ∀ P, phiHat (phi P) = (a : ℤ) • P
  phi_phiHat : ∀ P, phi (phiHat P) = (a : ℤ) • P
  psiHat_psi : ∀ P, psiHat (psi P) = (b : ℤ) • P
  psi_psiHat : ∀ P, psi (psiHat P) = (b : ℤ) • P
  phi'Hat_phi' : ∀ P, phi'Hat (phi' P) = (a : ℤ) • P
  phi'_phi'Hat : ∀ P, phi' (phi'Hat P) = (a : ℤ) • P
  psi'Hat_psi' : ∀ P, psi'Hat (psi' P) = (b : ℤ) • P
  psi'_psi'Hat : ∀ P, psi' (psi'Hat P) = (b : ℤ) • P
  /-- The diamond commutes. -/
  square : ∀ P, psi' (phi P) = phi' (psi P)
  /-- Isogenies are surjective on geometric points. -/
  phi_surjective : Surjective phi
  psi_surjective : Surjective psi
  psi'_surjective : Surjective psi'

/-- The `n`-torsion subgroup `E[n]` of an abelian group. -/
def nTorsion (E : Type*) [AddCommGroup E] (n : ℕ) : AddSubgroup E where
  carrier := {x | (n : ℤ) • x = 0}
  add_mem' := by
    intro x y hx hy
    simp only [Set.mem_setOf_eq] at *
    rw [smul_add, hx, hy, add_zero]
  zero_mem' := by simp
  neg_mem' := by
    intro x hx
    simp only [Set.mem_setOf_eq] at *
    rw [smul_neg, hx, neg_zero]

@[simp] theorem mem_nTorsion {E : Type*} [AddCommGroup E] {n : ℕ} {x : E} :
    x ∈ nTorsion E n ↔ (n : ℤ) • x = 0 := Iff.rfl

/-- If `n • x = 0` and `k ≡ 1 (mod n)` then `k • x = x`. -/
theorem zsmul_eq_self_of_one_add {E : Type*} [AddCommGroup E] {n k : ℤ} {x : E}
    (hx : n • x = 0) (hk : ∃ v : ℤ, k = 1 + n * v) : k • x = x := by
  obtain ⟨v, rfl⟩ := hk
  rw [add_smul, one_smul, mul_comm, mul_smul, hx, smul_zero, add_zero]

/-- The `n`-torsion of a product is the product of the `n`-torsions. -/
def nTorsionProdEquiv (A B : Type*) [AddCommGroup A] [AddCommGroup B] (n : ℕ) :
    nTorsion (A × B) n ≃+ nTorsion A n × nTorsion B n where
  toFun x := (⟨x.1.1, (Prod.ext_iff.mp x.2).1⟩, ⟨x.1.2, (Prod.ext_iff.mp x.2).2⟩)
  invFun y := ⟨(y.1.1, y.2.1), Prod.ext_iff.mpr ⟨y.1.2, y.2.2⟩⟩
  left_inv x := by ext <;> rfl
  right_inv y := by ext <;> rfl
  map_add' x y := rfl

/-- Cardinality of the `n`-torsion of a product. -/
theorem card_nTorsion_prod (A B : Type*) [AddCommGroup A] [AddCommGroup B] (n : ℕ) :
    Nat.card (nTorsion (A × B) n) = Nat.card (nTorsion A n) * Nat.card (nTorsion B n) := by
  rw [Nat.card_congr (nTorsionProdEquiv A B n).toEquiv, Nat.card_prod]

namespace Diamond

variable {E₁ E₂ E₃ E₄ : Type*} [AddCommGroup E₁] [AddCommGroup E₂]
    [AddCommGroup E₃] [AddCommGroup E₄] (D : Diamond E₁ E₂ E₃ E₄)

/-- The degree `N = a + b` of the associated `(N,N)`-isogeny. -/
def N : ℕ := D.a + D.b

/-! ### Coprimality bookkeeping -/

/-- If `a` and `b` are coprime then so are `a` and `N = a + b`. -/
theorem coprime_a_N (hab : Nat.Coprime D.a D.b) : Nat.Coprime D.a D.N := by
  show Nat.Coprime D.a (D.a + D.b)
  simp only [Nat.Coprime] at hab ⊢
  rw [Nat.gcd_comm, add_comm, Nat.gcd_add_self_left, Nat.gcd_comm]
  exact hab

/-- If `a` and `b` are coprime then so are `b` and `N = a + b`. -/
theorem coprime_b_N (hab : Nat.Coprime D.a D.b) : Nat.Coprime D.b D.N := by
  simp only [N, Nat.Coprime] at hab ⊢
  rw [Nat.gcd_add_self_right, Nat.gcd_comm]
  exact hab

/-- Bézout: `a` is invertible modulo `N = a + b` when `gcd(a,b) = 1`. -/
theorem exists_inv_a (hab : Nat.Coprime D.a D.b) :
    ∃ u v : ℤ, (D.a : ℤ) * u = 1 + (D.N : ℤ) * v := by
  obtain ⟨p, q, hpq⟩ := Nat.Coprime.isCoprime (D.coprime_a_N hab)
  exact ⟨p, -q, by linear_combination hpq⟩

/-- Bézout: `b` is invertible modulo `N = a + b` when `gcd(a,b) = 1`. -/
theorem exists_inv_b (hab : Nat.Coprime D.a D.b) :
    ∃ w v : ℤ, (D.b : ℤ) * w = 1 + (D.N : ℤ) * v := by
  obtain ⟨p, q, hpq⟩ := Nat.Coprime.isCoprime (D.coprime_b_N hab)
  exact ⟨p, -q, by linear_combination hpq⟩


/-! ### The two derived "dual square" identities -/

/-- Transporting the commutative square through the duals: `φ'^ ∘ ψ' = ψ ∘ φ^`.

This is the identity that makes the SIDH public torsion data usable: it says
that `ψ` is determined on the image of `φ^` by the pushforward `ψ'`. -/
theorem phi'Hat_psi' (Q : E₂) : D.phi'Hat (D.psi' Q) = D.psi (D.phiHat Q) := by
  obtain ⟨P, hP⟩ := D.phi_surjective Q
  rw [← hP]
  rw [D.square]
  rw [D.phi'Hat_phi']
  rw [D.phiHat_phi]
  simp

/-- The dual of the commutative square: `φ^ ∘ ψ'^ = ψ^ ∘ φ'^`. -/
theorem phiHat_psi'Hat (R : E₄) : D.phiHat (D.psi'Hat R) = D.psiHat (D.phi'Hat R) := by
  obtain ⟨Q, hQ⟩ := D.psi'_surjective R
  rw [← hQ, D.psi'Hat_psi', D.phiHat.map_zsmul, D.phi'Hat_psi', D.psiHat_psi]

/-- The remaining dual identity `ψ'^ ∘ φ' = φ ∘ ψ^`. -/
theorem psi'Hat_phi' (R : E₃) : D.psi'Hat (D.phi' R) = D.phi (D.psiHat R) := by
  obtain ⟨P, hP⟩ := D.psi_surjective R
  rw [← hP, ← D.square P, D.psiHat_psi]
  simp only [map_zsmul]
  rw [D.psi'Hat_psi']

/-! ### The Kani isogeny -/

/-- The **Kani isogeny** `F : E₁ × E₄ → E₂ × E₃` attached to a diamond,
given by the matrix `((φ, ψ'^), (-ψ, φ'^))`. -/
def kani : (E₁ × E₄) →+ (E₂ × E₃) :=
  AddMonoidHom.mk' (fun z => (D.phi z.1 + D.psi'Hat z.2, -D.psi z.1 + D.phi'Hat z.2))
    (by intro x y; simp only [Prod.fst_add, Prod.snd_add, map_add, Prod.mk_add_mk,
          Prod.mk.injEq, neg_add]; constructor <;> abel)

/-- The dual Kani isogeny `F^ : E₂ × E₃ → E₁ × E₄`, given by the transposed
matrix of duals `((φ^, -ψ^), (ψ', φ'))`. -/
def kaniDual : (E₂ × E₃) →+ (E₁ × E₄) :=
  AddMonoidHom.mk' (fun w => (D.phiHat w.1 - D.psiHat w.2, D.psi' w.1 + D.phi' w.2))
    (by intro x y; simp only [Prod.fst_add, Prod.snd_add, map_add, Prod.mk_add_mk,
          Prod.mk.injEq]; constructor <;> abel)

@[simp] theorem kani_apply (z : E₁ × E₄) :
    D.kani z = (D.phi z.1 + D.psi'Hat z.2, -D.psi z.1 + D.phi'Hat z.2) := rfl

@[simp] theorem kaniDual_apply (w : E₂ × E₃) :
    D.kaniDual w = (D.phiHat w.1 - D.psiHat w.2, D.psi' w.1 + D.phi' w.2) := rfl

/-- **Kani's lemma, multiplicative form.**  `F^ ∘ F = [N]` with `N = a + b`. -/
theorem kaniDual_kani (z : E₁ × E₄) : D.kaniDual (D.kani z) = (D.N : ℤ) • z := by
  have hN : (D.N : ℤ) = (D.a : ℤ) + (D.b : ℤ) := by simp [N]
  refine Prod.ext ?_ ?_
  · show D.phiHat (D.phi z.1 + D.psi'Hat z.2) - D.psiHat (-D.psi z.1 + D.phi'Hat z.2)
        = (D.N : ℤ) • z.1
    rw [map_add, map_add, map_neg, D.phiHat_phi, D.psiHat_psi, D.phiHat_psi'Hat, hN, add_zsmul]
    abel
  · show D.psi' (D.phi z.1 + D.psi'Hat z.2) + D.phi' (-D.psi z.1 + D.phi'Hat z.2)
        = (D.N : ℤ) • z.2
    rw [map_add, map_add, map_neg, D.square, D.psi'_psi'Hat, D.phi'_phi'Hat, hN, add_zsmul]
    abel

/-- **Kani's lemma, multiplicative form (other side).**  `F ∘ F^ = [N]`. -/
theorem kani_kaniDual (w : E₂ × E₃) : D.kani (D.kaniDual w) = (D.N : ℤ) • w := by
  have hN : (D.N : ℤ) = (D.a : ℤ) + (D.b : ℤ) := by simp [N]
  refine Prod.ext ?_ ?_
  · show D.phi (D.phiHat w.1 - D.psiHat w.2) + D.psi'Hat (D.psi' w.1 + D.phi' w.2)
        = (D.N : ℤ) • w.1
    rw [map_sub, map_add, D.phi_phiHat, D.psi'Hat_psi', D.psi'Hat_phi', hN, add_zsmul]
    abel
  · show -D.psi (D.phiHat w.1 - D.psiHat w.2) + D.phi'Hat (D.psi' w.1 + D.phi' w.2)
        = (D.N : ℤ) • w.2
    rw [map_sub, map_add, D.psi_psiHat, D.phi'Hat_phi', D.phi'Hat_psi', hN, add_zsmul]
    abel

/-- `F` is surjective: an immediate consequence of `F ∘ F^ = [N]` is that
`N • (E₂ × E₃)` lies in the image of `F`. -/
theorem nsmul_mem_range_kani (w : E₂ × E₃) : ∃ z, D.kani z = (D.N : ℤ) • w :=
  ⟨D.kaniDual w, D.kani_kaniDual w⟩

/-- The kernel of `F` is killed by `N`: `F` is an `(N,N)`-isogeny. -/
theorem N_smul_eq_zero_of_mem_ker {z : E₁ × E₄} (hz : D.kani z = 0) :
    (D.N : ℤ) • z = 0 := by
  rw [← D.kaniDual_kani, hz, map_zero]

/-! ### The kernel of the Kani isogeny -/

/-- The parametrisation `Q ↦ (φ^ Q, ψ' Q)` of the kernel of `F`. -/
def graphMap : E₂ →+ (E₁ × E₄) := (D.phiHat.prod D.psi')

@[simp] theorem graphMap_apply (Q : E₂) : D.graphMap Q = (D.phiHat Q, D.psi' Q) := rfl

/-- The graph of `E₂[N]` under `Q ↦ (φ^ Q, ψ' Q)` is contained in `ker F`. -/
theorem kani_graph {Q : E₂} (hQ : (D.N : ℤ) • Q = 0) : D.kani (D.graphMap Q) = 0 := by
  rw [kani_apply, graphMap_apply]
  rw [D.phi_phiHat Q, D.psi'Hat_psi' Q, D.phi'Hat_psi' Q]
  simp_all [N, add_smul]

/-- If `a` and `b` are coprime the graph parametrisation is injective; hence
the kernel of `F` has exactly as many points as `E₂[N]`. -/
theorem graphMap_injective (hab : Nat.Coprime D.a D.b) : Injective D.graphMap := by
  intro Q Q' h
  simp only [graphMap_apply, Prod.mk.injEq] at h
  have h1 : D.phiHat (Q - Q') = 0 := by simp [h.1]
  have h2 : D.psi' (Q - Q') = 0 := by simp [h.2]
  have hb : (D.b : ℤ) • (Q - Q') = 0 := by rw [← D.psi'Hat_psi']; simp [h2]
  have ha : (D.a : ℤ) • (Q - Q') = 0 := by rw [← D.phi_phiHat]; simp [h1]
  obtain ⟨x, y, hxy⟩ := Nat.Coprime.isCoprime hab
  have heq : (Q - Q') = (x * D.a + y * D.b : ℤ) • (Q - Q') := by simp [hxy]
  rw [add_smul, mul_zsmul, mul_zsmul, ha, hb] at heq
  simp at heq
  exact sub_eq_zero.mp heq

/-- **Kani's lemma.**  For coprime degrees, the kernel of the Kani isogeny is
*exactly* the graph `{ (φ^ Q, ψ' Q) : Q ∈ E₂[N] }`.

This is the statement exploited by the Castryck–Decru attack: the SIDH public
data (the images `ψ'` of the `N`-torsion, together with `φ^` on that torsion)
determines a subgroup of `E₁ × E₄` which is the kernel of an isogeny of smooth
degree `N²`, and hence can be computed. -/
theorem mem_ker_kani_iff (hab : Nat.Coprime D.a D.b) (z : E₁ × E₄) :
    D.kani z = 0 ↔ ∃ Q : E₂, (D.N : ℤ) • Q = 0 ∧ z = D.graphMap Q := by
  constructor
  · intro hz
    obtain ⟨u, v, huv⟩ := D.exists_inv_a hab
    obtain ⟨x, y⟩ := z
    have hz2 : -D.psi x + D.phi'Hat y = 0 := by simpa using congrArg Prod.snd hz
    have hN := D.N_smul_eq_zero_of_mem_ker hz
    have hNx : (D.N : ℤ) • x = 0 := by simpa using congrArg Prod.fst hN
    have hNy : (D.N : ℤ) • y = 0 := by simpa using congrArg Prod.snd hN
    have hpsi : D.psi x = D.phi'Hat y := by rwa [neg_add_eq_zero] at hz2
    refine ⟨u • D.phi x, ?_, ?_⟩
    · rw [smul_comm, ← map_zsmul, hNx, map_zero, smul_zero]
    · have hxx : D.phiHat (u • D.phi x) = x := by
        rw [map_zsmul, D.phiHat_phi, smul_smul, mul_comm u (D.a : ℤ)]
        exact zsmul_eq_self_of_one_add hNx ⟨v, huv⟩
      have hyy : D.psi' (u • D.phi x) = y := by
        rw [map_zsmul, D.square, hpsi, D.phi'_phi'Hat, smul_smul, mul_comm u (D.a : ℤ)]
        exact zsmul_eq_self_of_one_add hNy ⟨v, huv⟩
      rw [graphMap_apply, hxx, hyy]
  · rintro ⟨Q, hQ, rfl⟩
    exact D.kani_graph hQ

/-! ### The kernel does not split off either factor -/

/-- `ker F` meets `E₁ × 0` trivially. -/
theorem kani_ker_inter_left (hab : Nat.Coprime D.a D.b) {x : E₁}
    (hx : D.kani (x, 0) = 0) : x = 0 := by
  rw [kani_apply] at hx
  simp at hx
  have hphi : D.phi x = 0 := by simpa using hx.1
  have hpsi : D.psi x = 0 := by simpa using hx.2
  have ha : (D.a : ℤ) • x = 0 := by simp [← D.phiHat_phi, hphi]
  have hb : (D.b : ℤ) • x = 0 := by simp [← D.psiHat_psi, hpsi]
  obtain ⟨u, v, huv⟩ := Nat.Coprime.isCoprime hab
  rw [show x = (1 : ℤ) • x by simp, show (1 : ℤ) = u * (D.a : ℤ) + v * (D.b : ℤ) by rw [huv],
    add_zsmul, mul_zsmul, mul_zsmul]
  simp [ha, hb]

/-- `ker F` meets `0 × E₄` trivially. -/
theorem kani_ker_inter_right (hab : Nat.Coprime D.a D.b) {y : E₄}
    (hy : D.kani (0, y) = 0) : y = 0 := by
  rw [kani_apply] at hy
  simp at hy
  have h1 : D.psi'Hat y = 0 := by simpa using hy.1
  have h2 : D.phi'Hat y = 0 := by simpa using hy.2
  have ha : (D.a : ℤ) • y = 0 := by simp [← D.phi'_phi'Hat, h2]
  have hb : (D.b : ℤ) • y = 0 := by simp [← D.psi'_psi'Hat, h1]
  obtain ⟨u, v, huv⟩ := Nat.Coprime.isCoprime hab
  rw [show y = (1 : ℤ) • y by simp, show (1 : ℤ) = u * (D.a : ℤ) + v * (D.b : ℤ) by rw [huv],
    add_zsmul, mul_zsmul, mul_zsmul]
  simp [ha, hb]

/-! ### Degree of the shared secret -/

/-- The SIDH shared-secret isogeny `ψ' ∘ φ = φ' ∘ ψ : E₁ → E₄` has degree
`a * b`, in the sense that composing with its dual gives `[a*b]`. -/
theorem shared_degree (P : E₁) :
    D.phiHat (D.psi'Hat (D.psi' (D.phi P))) = ((D.a * D.b : ℕ) : ℤ) • P := by
  -- phiHat (psi'Hat (psi' (phi P)))
  -- = psiHat (phi'Hat (psi' (phi P)))  using phiHat_psi'Hat
  rw [D.phiHat_psi'Hat]
  -- = psiHat (psi (phiHat (phi P)))    using phi'Hat_psi'
  rw [D.phi'Hat_psi']
  -- = psiHat (psi (a • P))             using phiHat_phi
  rw [D.phiHat_phi]
  -- = psiHat (a • psi P)               homomorphism property
  rw [map_zsmul]
  -- = a • psiHat (psi P)               homomorphism property
  rw [map_zsmul]
  -- = a • (b • P)                      using psiHat_psi
  rw [D.psiHat_psi]
  -- = (a * b) • P
  rw [Nat.cast_mul, smul_smul]

/-- Both parties of the SIDH exchange compute the same isogeny to the shared
curve; in particular the two composite maps have the same kernel. -/
theorem shared_ker_eq :
    ((D.psi'.comp D.phi).ker) = ((D.phi'.comp D.psi).ker) := by
  congr 1
  ext P
  exact D.square P

/-! ### `ker F` is isomorphic to `E₂[N]` -/

/-- The graph parametrisation, viewed as a map into the kernel of `F`. -/
def graphToKer : nTorsion E₂ D.N →+ D.kani.ker where
  toFun Q := ⟨D.graphMap Q.1, D.kani_graph Q.2⟩
  map_zero' := by ext <;> simp
  map_add' := by intro Q R; ext <;> simp

/-- **Degree of the Kani isogeny.**  For coprime degrees the kernel of `F` is
isomorphic to the full `N`-torsion of `E₂`; since `E₂[N] ≅ (ℤ/N)²` for an
elliptic curve, `F` is an isogeny of degree `N²`. -/
noncomputable def kerEquivTorsion (hab : Nat.Coprime D.a D.b) :
    nTorsion E₂ D.N ≃+ D.kani.ker :=
  AddEquiv.ofBijective D.graphToKer
    ⟨fun Q Q' h => Subtype.ext (D.graphMap_injective hab (congrArg Subtype.val h)), by
      rintro ⟨z, hz⟩
      obtain ⟨Q, hQ, rfl⟩ := (D.mem_ker_kani_iff hab z).mp (AddMonoidHom.mem_ker.mp hz)
      exact ⟨⟨Q, hQ⟩, rfl⟩⟩

/-- The kernel of the Kani isogeny has exactly `N²` points, given that the
`N`-torsion of an elliptic curve has `N²` points. -/
theorem card_ker_kani (hab : Nat.Coprime D.a D.b)
    (hcard : Nat.card (nTorsion E₂ D.N) = D.N ^ 2) :
    Nat.card D.kani.ker = D.N ^ 2 := by
  rw [← hcard]
  exact Nat.card_congr (kerEquivTorsion D hab).symm

/-! ### `ker F` is the graph of an isomorphism `E₁[N] ≃ E₄[N]` -/

/-- The explicit gluing map `x ↦ u • ψ'(φ x)`, for `u` an inverse of `a`
modulo `N`. -/
def glueMap (u : ℤ) : E₁ →+ E₄ :=
  AddMonoidHom.mk' (fun x => u • D.psi' (D.phi x)) (by intro x y; simp [smul_add])

/-- The explicit inverse gluing map `y ↦ w • φ^(ψ'^ y)`, for `w` an inverse of
`b` modulo `N`. -/
def unglueMap (w : ℤ) : E₄ →+ E₁ :=
  AddMonoidHom.mk' (fun y => w • D.phiHat (D.psi'Hat y)) (by intro x y; simp [smul_add])

@[simp] theorem glueMap_apply (u : ℤ) (x : E₁) : D.glueMap u x = u • D.psi' (D.phi x) := rfl

@[simp] theorem unglueMap_apply (w : ℤ) (y : E₄) :
    D.unglueMap w y = w • D.phiHat (D.psi'Hat y) := rfl

/-- The gluing map sends `N`-torsion to `N`-torsion. -/
theorem glueMap_mem_torsion (u : ℤ) {x : E₁} (hx : (D.N : ℤ) • x = 0) :
    (D.N : ℤ) • D.glueMap u x = 0 := by
  rw [glueMap_apply, smul_comm, ← map_zsmul, ← map_zsmul, ← map_zsmul, hx]
  simp

/-- The inverse gluing map sends `N`-torsion to `N`-torsion. -/
theorem unglueMap_mem_torsion (w : ℤ) {y : E₄} (hy : (D.N : ℤ) • y = 0) :
    (D.N : ℤ) • D.unglueMap w y = 0 := by
  rw [unglueMap_apply, smul_comm, ← map_zsmul, ← map_zsmul, ← map_zsmul, hy]
  simp

/-- **The kernel of `F` is a graph over `E₁[N]`**: for `u` inverse to `a` mod
`N`, every `N`-torsion point `x` of `E₁` is glued to `u • ψ'(φ x)`. -/
theorem glueMap_mem_ker {u : ℤ}
    (hu : ∃ v : ℤ, (D.a : ℤ) * u = 1 + (D.N : ℤ) * v) {x : E₁} (hx : (D.N : ℤ) • x = 0) :
    D.kani (x, D.glueMap u x) = 0 := by
  obtain ⟨v, hv⟩ := hu
  have hQ : (D.N : ℤ) • (u • D.phi x) = 0 := by
    rw [smul_comm, ← map_zsmul, hx, map_zero, smul_zero]
  have hx' : D.phiHat (u • D.phi x) = x := by
    rw [map_zsmul, D.phiHat_phi, smul_smul, mul_comm u (D.a : ℤ), hv, add_smul, one_smul, mul_comm (D.N : ℤ) v,
      mul_smul, hx, smul_zero, add_zero]
  have h := D.kani_graph hQ
  rw [graphMap_apply, hx', map_zsmul] at h
  exact h

/-- The two gluing maps are mutually inverse on the `N`-torsion. -/
theorem unglueMap_glueMap {u w : ℤ} (hu : ∃ v : ℤ, (D.a : ℤ) * u = 1 + (D.N : ℤ) * v)
    (hw : ∃ v : ℤ, (D.b : ℤ) * w = 1 + (D.N : ℤ) * v) {x : E₁} (hx : (D.N : ℤ) • x = 0) :
    D.unglueMap w (D.glueMap u x) = x := by
  obtain ⟨v, hv⟩ := hu
  obtain ⟨v', hv'⟩ := hw
  rw [unglueMap_apply, glueMap_apply, map_zsmul, D.psi'Hat_psi', map_zsmul, map_zsmul,
    D.phiHat_phi, smul_smul, smul_smul, smul_smul]
  refine zsmul_eq_self_of_one_add hx ⟨v + v' + (D.N : ℤ) * v * v', ?_⟩
  linear_combination ((D.b : ℤ) * w) * hv + (1 + (D.N : ℤ) * v) * hv'

/-- **The attack recovers the secret action from the kernel.**  On the
`N`-torsion, `a` times the gluing map (which is read off from `ker F`) is the
composite `ψ' ∘ φ`; since `a` is invertible modulo `N`, knowledge of `ker F` is
equivalent to knowledge of the secret isogeny on the `N`-torsion. -/
theorem smul_glueMap {u : ℤ} (hu : ∃ v : ℤ, (D.a : ℤ) * u = 1 + (D.N : ℤ) * v)
    {x : E₁} (hx : (D.N : ℤ) • x = 0) :
    (D.a : ℤ) • D.glueMap u x = D.psi' (D.phi x) := by
  obtain ⟨v, hv⟩ := hu
  have hz : (D.N : ℤ) • D.psi' (D.phi x) = 0 := by
    rw [← map_zsmul, ← map_zsmul, hx, map_zero, map_zero]
  rw [glueMap_apply, smul_smul, hv, add_smul, one_smul, mul_comm (D.N : ℤ) v, mul_smul, hz,
    smul_zero, add_zero]

/-- Every `N`-torsion point of `E₁` has a unique partner in `E₄` inside the
kernel of `F`. -/
theorem exists_unique_partner_left (hab : Nat.Coprime D.a D.b) {x : E₁}
    (hx : (D.N : ℤ) • x = 0) : ∃! y : E₄, D.kani (x, y) = 0 := by
  obtain ⟨u, v, huv⟩ := D.exists_inv_a hab
  refine ⟨D.glueMap u x, D.glueMap_mem_ker ⟨v, huv⟩ hx, fun y hy => ?_⟩
  have h0 : D.kani (0, y - D.glueMap u x) = 0 := by
    have : D.kani (0, y - D.glueMap u x)
        = D.kani (x, y) - D.kani (x, D.glueMap u x) := by
      rw [← map_sub]
      congr 1
      simp
    rw [this, hy, D.glueMap_mem_ker ⟨v, huv⟩ hx, sub_zero]
  have := D.kani_ker_inter_right hab h0
  exact sub_eq_zero.mp this

/-- Every `N`-torsion point of `E₄` has a unique partner in `E₁` inside the
kernel of `F`. -/
theorem exists_unique_partner_right (hab : Nat.Coprime D.a D.b) {y : E₄}
    (hy : (D.N : ℤ) • y = 0) : ∃! x : E₁, D.kani (x, y) = 0 := by
  obtain ⟨w, v, hwv⟩ := D.exists_inv_b hab
  have hQ : (D.N : ℤ) • (w • D.psi'Hat y) = 0 := by
    rw [smul_comm, ← map_zsmul, hy, map_zero, smul_zero]
  have hy' : D.psi' (w • D.psi'Hat y) = y := by
    rw [map_zsmul, D.psi'_psi'Hat, smul_smul, mul_comm w (D.b : ℤ)]
    exact zsmul_eq_self_of_one_add hy ⟨v, hwv⟩
  have hker : D.kani (D.unglueMap w y, y) = 0 := by
    have h := D.kani_graph hQ
    rw [graphMap_apply, hy', map_zsmul] at h
    exact h
  refine ⟨D.unglueMap w y, hker, fun x hx => ?_⟩
  have h0 : D.kani (x - D.unglueMap w y, 0) = 0 := by
    have : D.kani (x - D.unglueMap w y, 0)
        = D.kani (x, y) - D.kani (D.unglueMap w y, y) := by
      rw [← map_sub]
      congr 1
      simp
    rw [this, hx, hker, sub_zero]
  have := D.kani_ker_inter_left hab h0
  exact sub_eq_zero.mp this

/-- Subgroup form of Kani's lemma: `ker F` is the image of `E₂[N]` under the
graph parametrisation. -/
theorem ker_kani_eq_map (hab : Nat.Coprime D.a D.b) :
    D.kani.ker = (nTorsion E₂ D.N).map D.graphMap := by
  ext z
  simp only [AddMonoidHom.mem_ker, AddSubgroup.mem_map, mem_nTorsion,
    D.mem_ker_kani_iff hab, eq_comm]

/-- The gluing map as a homomorphism `E₁[N] → E₄[N]`. -/
def glueTorsion (u : ℤ) : nTorsion E₁ D.N →+ nTorsion E₄ D.N where
  toFun x := ⟨D.glueMap u x.1, D.glueMap_mem_torsion u x.2⟩
  map_zero' := by ext; simp
  map_add' x y := by ext; simp

@[simp] theorem glueTorsion_coe (u : ℤ) (x : nTorsion E₁ D.N) :
    (D.glueTorsion u x : E₄) = D.glueMap u x.1 := rfl

/-- **`ker F` is the graph of an isomorphism `E₁[N] ≃ E₄[N]`.**  This is the
form of Kani's lemma used to glue the two curves of an SIDH instance into a
single abelian surface. -/
theorem glueTorsion_bijective (hab : Nat.Coprime D.a D.b) {u : ℤ}
    (hu : ∃ v : ℤ, (D.a : ℤ) * u = 1 + (D.N : ℤ) * v) :
    Function.Bijective (D.glueTorsion u) := by
  constructor
  · intro x x' h
    have h1 : D.kani (x.1, D.glueMap u x.1) = 0 := D.glueMap_mem_ker hu x.2
    have h2 : D.kani (x'.1, D.glueMap u x'.1) = 0 := D.glueMap_mem_ker hu x'.2
    have hval : D.glueMap u x.1 = D.glueMap u x'.1 := congrArg Subtype.val h
    have hy : (D.N : ℤ) • D.glueMap u x.1 = 0 := D.glueMap_mem_torsion u x.2
    have h2' : D.kani (x'.1, D.glueMap u x.1) = 0 := by rw [hval]; exact h2
    exact Subtype.ext ((D.exists_unique_partner_right hab hy).unique h1 h2')
  · rintro ⟨y, hy⟩
    obtain ⟨x, hx, -⟩ := D.exists_unique_partner_right hab hy
    have hxT : (D.N : ℤ) • x = 0 := by
      simpa using congrArg Prod.fst (D.N_smul_eq_zero_of_mem_ker hx)
    exact ⟨⟨x, hxT⟩, Subtype.ext ((D.exists_unique_partner_left hab hxT).unique
      (D.glueMap_mem_ker hu hxT) hx)⟩

/-! ## A concrete isogeny diamond: complex multiplication by Gaussian integers

The theory above is not vacuous.  We exhibit an explicit diamond of coprime
degrees `a = 5`, `b = 2` modelled on the CM elliptic curve `E = ℂ/ℤ[i]`, whose
endomorphism ring is the Gaussian integers, with `deg [α] = N(α) = α ᾱ` and
dual `[α]^ = [ᾱ]`.  Its group of torsion points is `(ℚ/ℤ)²` with `ℤ[i]` acting
through the matrix `u + v i ↦ ((u, -v), (v, u))`. -/

/-- The group `ℚ/ℤ`, the torsion of a one–dimensional complex torus. -/
abbrev QZ := ℚ ⧸ AddSubgroup.zmultiples (1 : ℚ)

/-- `ℚ/ℤ` is divisible. -/
theorem QZ_divisible {d : ℤ} (hd : d ≠ 0) (x : QZ) : ∃ y : QZ, d • y = x := by
  induction x using Quotient.inductionOn
  case h a =>
    refine ⟨Quotient.mk _ (a / d), ?_⟩
    have key : (d : ℤ) • (a / d : ℚ) = a := by simp [zsmul_eq_mul, mul_div_cancel₀, hd]
    apply Quotient.eq.mpr
    simp [key]
    exact (QuotientAddGroup.con (AddSubgroup.zmultiples (1 : ℚ))).refl a

/-- The homomorphism `ℤ → ℚ/ℤ`, `k ↦ k/n`, whose image is the `n`-torsion. -/
noncomputable def QZfrac (n : ℕ) : ℤ →+ QZ :=
  (QuotientAddGroup.mk' (AddSubgroup.zmultiples (1 : ℚ))).comp
    (zmultiplesHom ℚ ((n : ℚ)⁻¹))

theorem QZfrac_apply (n : ℕ) (k : ℤ) :
    QZfrac n k = QuotientAddGroup.mk ((k : ℚ) / n) := by
  simp [QZfrac, zsmul_eq_mul, div_eq_mul_inv]

/-- An element of `ℚ/ℤ` is zero exactly when a representative is an integer. -/
theorem QZ_mk_eq_zero (x : ℚ) :
    (QuotientAddGroup.mk x : QZ) = 0 ↔ ∃ k : ℤ, (k : ℚ) = x := by
  rw [show (0 : QZ) = QuotientAddGroup.mk 0 by rfl]
  rw [QuotientAddGroup.eq_iff_sub_mem]
  simp [AddSubgroup.mem_zmultiples_iff]

/-- The kernel of `k ↦ k/n` is `nℤ`. -/
theorem QZ_ker_QZfrac {n : ℕ} (hn : 0 < n) :
    (QZfrac n).ker = AddSubgroup.zmultiples (n : ℤ) := by
  ext k
  simp only [AddMonoidHom.mem_ker, QZfrac_apply, QZ_mk_eq_zero]
  have hn' : (n : ℚ) ≠ 0 := by norm_cast; linarith
  constructor
  · rintro ⟨m, hm⟩
    exact ⟨m, by rw [eq_div_iff hn'] at hm; norm_cast at hm⟩
  · rintro ⟨m, rfl⟩
    refine ⟨m, ?_⟩
    field_simp
    norm_cast

/-- The image of `k ↦ k/n` is the `n`-torsion of `ℚ/ℤ`. -/
theorem QZ_range_QZfrac {n : ℕ} (hn : 0 < n) :
    (QZfrac n).range = nTorsion QZ n := by
  ext x
  simp only [AddMonoidHom.mem_range, mem_nTorsion]
  have hn' : (n : ℚ) ≠ 0 := by norm_cast; linarith
  constructor
  · rintro ⟨k, rfl⟩
    rw [QZfrac_apply]
    have h1 : (n : ℤ) • (QuotientAddGroup.mk ((k : ℚ) / n) : ℚ ⧸ AddSubgroup.zmultiples 1) =
            QuotientAddGroup.mk ((n : ℚ) * ((k : ℚ) / n)) := by
      simp
    rw [h1]
    have h2 : (n : ℚ) * ((k : ℚ) / n) = k := by field_simp
    rw [h2, QZ_mk_eq_zero]
    exact ⟨k, rfl⟩
  · intro hx
    obtain ⟨q, hq⟩ := Quotient.exists_rep x
    rw [← hq] at hx ⊢
    rw [show (n : ℤ) • (QuotientAddGroup.mk q : QZ) = QuotientAddGroup.mk ((n : ℚ) * q) by
      simp, QZ_mk_eq_zero] at hx
    obtain ⟨k, hk⟩ := hx
    refine ⟨k, ?_⟩
    rw [QZfrac_apply]
    congr 1
    field_simp
    linarith

/-- Multiplication by the Gaussian integer `u + v i` on `(ℚ/ℤ)² = ℂ/ℤ[i]`
(torsion), i.e. the endomorphism with matrix `((u, -v), (v, u))`. -/
noncomputable def gaussHom (u v : ℤ) : QZ × QZ →+ QZ × QZ :=
  AddMonoidHom.mk' (fun p => (u • p.1 - v • p.2, v • p.1 + u • p.2))
    (by intro p q; simp only [Prod.fst_add, Prod.snd_add, smul_add, Prod.mk_add_mk,
          Prod.mk.injEq]; constructor <;> abel)

@[simp] theorem gaussHom_apply (u v : ℤ) (p : QZ × QZ) :
    gaussHom u v p = (u • p.1 - v • p.2, v • p.1 + u • p.2) := rfl

/-- Multiplication by Gaussian integers is multiplicative: `[z] ∘ [z'] = [z z']`. -/
theorem gaussHom_comp (u v u' v' : ℤ) (p : QZ × QZ) :
    gaussHom u v (gaussHom u' v' p) = gaussHom (u * u' - v * v') (u * v' + v * u') p := by
  simp only [gaussHom_apply]
  refine Prod.ext ?_ ?_ <;>
    simp_rw [smul_sub, smul_add, smul_smul, add_smul, sub_smul] <;> abel

/-- `[ᾱ] ∘ [α] = [N(α)]`: the norm relation defining the dual isogeny. -/
theorem gaussHom_conj (u v : ℤ) (p : QZ × QZ) :
    gaussHom u (-v) (gaussHom u v p) = (u ^ 2 + v ^ 2 : ℤ) • p := by
  rw [gaussHom_comp, show u * u - -v * v = u ^ 2 + v ^ 2 by ring,
    show u * v + -v * u = 0 by ring]
  simp [gaussHom, Prod.ext_iff]

/-- A nonzero Gaussian integer acts surjectively on the divisible group
`(ℚ/ℤ)²`. -/
theorem gaussHom_surjective {u v : ℤ} (h : u ^ 2 + v ^ 2 ≠ 0) :
    Function.Surjective (gaussHom u v) := by
  intro w
  obtain ⟨q1, hq1⟩ := QZ_divisible h w.1
  obtain ⟨q2, hq2⟩ := QZ_divisible h w.2
  refine ⟨gaussHom u (-v) (q1, q2), ?_⟩
  have hconj := gaussHom_conj u (-v) (q1, q2)
  rw [neg_neg, neg_sq] at hconj
  rw [hconj]
  exact Prod.ext hq1 hq2

/-- `gaussHom` is additive in the Gaussian integer. -/
theorem gaussHom_add (u v u' v' : ℤ) (p : QZ × QZ) :
    gaussHom (u + u') (v + v') p = gaussHom u v p + gaussHom u' v' p := by
  simp only [gaussHom_apply, add_smul, Prod.mk_add_mk, Prod.mk.injEq]
  constructor <;> abel

/-- `gaussHom 1 0` is the identity. -/
theorem gaussHom_one (p : QZ × QZ) : gaussHom 1 0 p = p := by
  simp [gaussHom]

/-- An explicit isogeny diamond with coprime degrees `a = 5` (multiplication by
`1 + 2i`) and `b = 2` (multiplication by `1 + i`) on the CM torus `ℂ/ℤ[i]`. -/
noncomputable def cmDiamond : Diamond (QZ × QZ) (QZ × QZ) (QZ × QZ) (QZ × QZ) where
  a := 5
  b := 2
  phi := gaussHom 1 2
  psi := gaussHom 1 1
  phi' := gaussHom 1 2
  psi' := gaussHom 1 1
  phiHat := gaussHom 1 (-2)
  psiHat := gaussHom 1 (-1)
  phi'Hat := gaussHom 1 (-2)
  psi'Hat := gaussHom 1 (-1)
  phiHat_phi P := by simpa using gaussHom_conj 1 2 P
  phi_phiHat P := by simpa using gaussHom_conj 1 (-2) P
  psiHat_psi P := by simpa using gaussHom_conj 1 1 P
  psi_psiHat P := by simpa using gaussHom_conj 1 (-1) P
  phi'Hat_phi' P := by simpa using gaussHom_conj 1 2 P
  phi'_phi'Hat P := by simpa using gaussHom_conj 1 (-2) P
  psi'Hat_psi' P := by simpa using gaussHom_conj 1 1 P
  psi'_psi'Hat P := by simpa using gaussHom_conj 1 (-1) P
  square P := by rw [gaussHom_comp, gaussHom_comp]; norm_num
  phi_surjective := gaussHom_surjective (by norm_num)
  psi_surjective := gaussHom_surjective (by norm_num)
  psi'_surjective := gaussHom_surjective (by norm_num)

/-- The degrees of the concrete diamond are coprime, so all results above
apply to it; in particular the theory of Kani diamonds is non-vacuous. -/
theorem cmDiamond_coprime : Nat.Coprime cmDiamond.a cmDiamond.b := by decide

/-- The Kani isogeny of the concrete diamond has `N = 7`. -/
theorem cmDiamond_N : cmDiamond.N = 7 := rfl

/-- Instantiation of Kani's lemma at the concrete Gaussian diamond: the kernel
of the associated `(7,7)`-isogeny of abelian surfaces is exactly the graph of
the `7`-torsion of the second curve. -/
theorem cmDiamond_ker (z : (QZ × QZ) × (QZ × QZ)) :
    cmDiamond.kani z = 0 ↔ ∃ Q, (7 : ℤ) • Q = 0 ∧ z = cmDiamond.graphMap Q := by
  simpa [cmDiamond_N] using cmDiamond.mem_ker_kani_iff cmDiamond_coprime z

/-- Compatibility of `gaussHom` with multiplication of Gaussian integers. -/
theorem gaussHom_mul_apply (z w : GaussianInt) (p : QZ × QZ) :
    gaussHom (z * w).re (z * w).im p = gaussHom z.re z.im (gaussHom w.re w.im p) := by
  rw [gaussHom_comp]
  simp [sub_eq_add_neg]

/-- Compatibility of `gaussHom` with addition of Gaussian integers. -/
theorem gaussHom_add_apply (z w : GaussianInt) (p : QZ × QZ) :
    gaussHom (z + w).re (z + w).im p = gaussHom z.re z.im p + gaussHom w.re w.im p := by
  simpa using gaussHom_add z.re z.im w.re w.im p

/-- The zero Gaussian integer acts as zero. -/
theorem gaussHom_zero (p : QZ × QZ) : gaussHom 0 0 p = 0 := by
  simp [gaussHom]

/-- **Complex multiplication.**  The Gaussian integers embed in the
endomorphism ring of the torsion group of `ℂ/ℤ[i]`. -/
noncomputable def gaussEnd : GaussianInt →+* AddMonoid.End (QZ × QZ) where
  toFun z := gaussHom z.re z.im
  map_one' := by exact AddMonoidHom.ext fun p => gaussHom_one p
  map_mul' z w := by exact AddMonoidHom.ext fun p => gaussHom_mul_apply z w p
  map_zero' := by exact AddMonoidHom.ext fun p => gaussHom_zero p
  map_add' z w := by exact AddMonoidHom.ext fun p => gaussHom_add_apply z w p

/-- An integer divisible by every positive integer is zero. -/
theorem int_eq_zero_of_forall_dvd {w : ℤ} (h : ∀ m : ℕ, 0 < m → ((m : ℤ) ∣ w)) :
    w = 0 := by
  by_contra hw
  have habs : 0 < w.natAbs := Int.natAbs_pos.mpr hw
  have hdvd := h (w.natAbs + 1) (by linarith)
  obtain ⟨k, hk⟩ := hdvd
  have hk_ne : k ≠ 0 := by
    intro hk0
    rw [hk0, mul_zero] at hk
    exact hw hk
  have hkeq : w.natAbs = (w.natAbs + 1) * k.natAbs := by
    have := congr_arg Int.natAbs hk
    simp [Int.natAbs_mul] at this
    show w.natAbs = (w.natAbs + 1) * k.natAbs
    have heq : |w| + 1 = ((w.natAbs + 1 : ℕ) : ℤ) := by
      rw [Int.abs_eq_natAbs]
      norm_cast
    rw [heq, Int.natAbs_natCast] at this
    exact this
  linarith [Nat.le_mul_of_pos_right (w.natAbs + 1) (Int.natAbs_pos.mpr hk_ne) ]

/-- An integer acting trivially on every point `1/m` of `ℚ/ℤ` is zero. -/
theorem int_eq_zero_of_smul_QZfrac {w : ℤ}
    (h : ∀ m : ℕ, 0 < m → w • QZfrac m 1 = 0) : w = 0 := by
  refine int_eq_zero_of_forall_dvd fun m hm => ?_
  have hw : QZfrac m w = 0 := by
    have h1 : QZfrac m w = w • QZfrac m 1 := by
      rw [← map_zsmul (QZfrac m) w (1 : ℤ), smul_eq_mul, mul_one]
    rw [h1, h m hm]
  have hmem : w ∈ (QZfrac m).ker := hw
  rw [QZ_ker_QZfrac hm, AddSubgroup.mem_zmultiples_iff] at hmem
  obtain ⟨c, hc⟩ := hmem
  exact ⟨c, by rw [← hc, smul_eq_mul, mul_comm]⟩

/-- If multiplication by `u + v i` kills all torsion points, then `u = v = 0`. -/
theorem gaussHom_eq_zero_iff {u v : ℤ} (h : ∀ p, gaussHom u v p = 0) :
    u = 0 ∧ v = 0 := by
  constructor
  · refine int_eq_zero_of_smul_QZfrac fun m hm => ?_
    have hp := h (QZfrac m 1, 0)
    have := congrArg Prod.fst hp
    simpa using this
  · refine int_eq_zero_of_smul_QZfrac fun m hm => ?_
    have hp := h (QZfrac m 1, 0)
    have := congrArg Prod.snd hp
    simpa using this

/-- The complex multiplication action is faithful. -/
theorem gaussEnd_injective : Function.Injective gaussEnd := by
  intro z w hzw
  have key : (z - w).re = 0 ∧ (z - w).im = 0 := by
    apply gaussHom_eq_zero_iff
    intro p
    have := AddMonoidHom.ext_iff.mp hzw p
    simp [gaussEnd, gaussHom] at this ⊢
    have h1 := this.1
    have h2 := this.2
    simp only [sub_zsmul]
    refine ⟨?_, ?_⟩
    · trans (z.re • p.1 - z.im • p.2) - (w.re • p.1 - w.im • p.2)
      · abel
      · rw [h1]; abel
    · trans (z.im • p.1 + z.re • p.2) - (w.im • p.1 + w.re • p.2)
      · abel
      · rw [h2]; abel
  ext <;> simp_all [sub_eq_zero]

/-- The `n`-torsion of `ℚ/ℤ` is cyclic of order `n`. -/
theorem card_nTorsion_QZ {n : ℕ} (hn : 0 < n) : Nat.card (nTorsion QZ n) = n := by
  rw [← QZ_range_QZfrac hn,
    ← Nat.card_congr (QuotientAddGroup.quotientKerEquivRange (QZfrac n)).toEquiv,
    QZ_ker_QZfrac hn,
    Nat.card_congr (Int.quotientZMultiplesNatEquivZMod n).toEquiv, Nat.card_zmod]

/-- The concrete Kani isogeny has kernel of order `N² = 49`, as predicted by
Kani's lemma. -/
theorem cmDiamond_card_ker : Nat.card cmDiamond.kani.ker = 49 := by
  have h : Nat.card (nTorsion (QZ × QZ) cmDiamond.N) = cmDiamond.N ^ 2 := by
    rw [cmDiamond_N, card_nTorsion_prod, card_nTorsion_QZ (by norm_num)]
    ring
  have := cmDiamond.card_ker_kani cmDiamond_coprime h
  rwa [cmDiamond_N] at this

end Diamond

end Cryptography.SIDH