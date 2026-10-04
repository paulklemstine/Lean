/-
# HINT-SIZE-SCALING: why the hint value is size-stable (FACT round 37 #1, paper 129)

Round 37 #1 (exp 464) reads the **hint value**
`I((p mod m*, q mod m*) ; L) - I(N mod m* ; L)` of four semiprime batteries at factor sizes
`k = 14, 18, 22` and finds it flat to `≤ 5.3%` over a `16384`-fold span, with an exception at
`k = 10` (thin prime pool) and a which-factor wall that holds only for the *conditional*
instrument.  This file proves the structural theorems behind every one of these observations;
`Logic.HintSizeScalingInstances` evaluates the four plateaus exactly.

## Main results

* `mutInfo_eq_sum_miTerm`, `miTerm_eq_logb` — the pointwise form of the catalog's counting
  mutual information (`CyclicTypeChannel.mutInfo`).
* `mutInfo_transport`, `uEnt_transport` — **uniform-fibre transport**: a map all of whose fibres
  have the same size preserves mutual information as soon as the pointwise count ratios agree.
* `mutInfo_blowup`, **`hint_blowup`** — **SIZE-STABILITY**: replicating every residue class by
  any number `|F|` of prime identities (i.e. going to any factor size) leaves every mutual
  information and the hint value *exactly* unchanged.  The hint value is a functional of the
  class-level law only; there is no size law to find.
* `mutInfo_pair_lift`, `mutInfo_prod_lift`, **`hint_residue_lift`** — **the residue-lift
  theorem**: for any finite abelian conductor group `G` (e.g. `(ℤ/m*)ˣ`), any surjective dial
  `ψ : G ↠ H` and any label seeing the residues only through `ψ` plus an independent Frobenius
  coin, the hint value on the residue views equals the hint value of the small dial box
  `(H × H) × C`.  Plateau values are therefore independent of size *and* of conductor.
* `condEnt_eq_zero_of_factor`, `hint_eq_condEnt_of_residue_function` — **abelian residual
  entropy is exactly `0`**: for residue-function labels the hint value is `H(L | N)`.
* `hint_eq_sub_residual`, `hint_le_condEnt`, **`hint_eq_condEnt_of_injective`** — **the
  pool-floor exception, formally**: `hint = H(L|N) - H(L|P)`; a pool that does not resolve the
  classes can only *inflate* the hint value, by at most the population residual `H(L | P)`, and
  a one-prime-per-class pool attains the ceiling `H(L | N)` for every label.
* `card_orient_half`, **`which_factor_wall`** — **the which-factor wall is exact**: for any
  swap-invariant battery, any orientation bit and any symmetric view,
  `I(orientation ; view) = 0`.
* `naive_instrument_fails` — **the instrument lesson**: an explicit battery on which the
  unconditional statistic `I(O ; p mod 5)` reads a full bit while the conditional statistic reads
  exactly `0`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): (H1) the size-stability is not empirical luck but an invariance — the hint
  value depends only on the class-level law; (H2) the plateau is a dial invariant computable on a
  box of size `|H|² |C|`, independent of the conductor; (H3) the `k = 10` excess is the residual
  `H(L|P)` leaking through an unresolved pool and is bounded by it; (H4) the wall is an exact
  symmetry statement, valid only conditionally.
Experiment (Stage 2): exact enumeration of the `8100`-point `S₃` residue box mod `31` gives hint
  `0.500000`; the one-prime-per-class pool gives `1.2725 … 1.2871` over six type assignments
  (ceiling `H(L|N) = 1.3070`); three seeded `n = 15000` plug-in replications of the ideal law
  give `0.5532, 0.5453, 0.5520`, bracketing the reported `0.5425 / 0.5415` (see
  `ComputationalEvidence.md`).
Analysis (Stage 3): (H1)–(H4) are theorems below.  The reported `S₃` plateau `≈ 0.54` is the
  exact value `1/2` plus plug-in bias of the `900`-cell pair view (Miller–Madow estimate
  `840 / (2 · 15000 · ln 2) ≈ 0.040`).
Critique (Stage 4): the population model (uniform residues, Chebotarev coin independent of the
  residue given the dial) is the Dirichlet–Chebotarev limit, an assumption about the
  distribution, not a theorem about finite sets of primes; `hint_blowup` is uniform
  replication, so real pools that are *unbalanced* per class are covered only by the
  inequality `hint_le_condEnt`.  No `native_decide`; all entropies exact.
-/
import Shared.CyclicTypeChannelNonneg
import Physics.AbelianLadderSexticCRT

namespace HintSizeScaling

open Finset CyclicTypeChannel

/-! ## 1. The pointwise form of the counting mutual information -/

section Pointwise

variable {α β γ : Type*} [DecidableEq β] [DecidableEq γ]

/-- The pointwise mutual-information density `log₂ (|s| · n(g,k) / (n(g) · n(k)))` at the
sample `x`, written as a signed sum of four logarithms of fibre sizes. -/
noncomputable def miTerm (s : Finset α) (g : α → β) (k : α → γ) (x : α) : ℝ :=
  Real.logb 2 s.card - Real.logb 2 (#{y ∈ s | g y = g x} : ℝ)
    - Real.logb 2 (#{y ∈ s | k y = k x} : ℝ)
    + Real.logb 2 (#{y ∈ s | k y = k x ∧ g y = g x} : ℝ)

/-- **Pointwise form.**  The counting mutual information is the average over the sample of the
pointwise density `miTerm`. -/
theorem mutInfo_eq_sum_miTerm (s : Finset α) (g : α → β) (k : α → γ) (hs : s.Nonempty) :
    mutInfo s g k = (∑ x ∈ s, miTerm s g k x) / s.card := by
  classical
  rw [mutInfo_eq_double s g k hs]
  have hfib : ∑ x ∈ s, miTerm s g k x = ∑ c ∈ s.image k, ∑ v ∈ s.image g,
      (#{x ∈ s | k x = c ∧ g x = v} : ℝ) *
        (Real.logb 2 (s.card : ℝ) - Real.logb 2 (#{x ∈ s | g x = v} : ℝ)
          - Real.logb 2 (#{x ∈ s | k x = c} : ℝ)
          + Real.logb 2 (#{x ∈ s | k x = c ∧ g x = v} : ℝ)) := by
    rw [← Finset.sum_fiberwise_of_maps_to (s := s) (t := s.image k) (g := k)
      (fun x hx => mem_image_of_mem k hx)]
    refine Finset.sum_congr rfl fun c _ => ?_
    rw [← Finset.sum_fiberwise_of_maps_to (s := {x ∈ s | k x = c}) (t := s.image g) (g := g)
      (fun x hx => mem_image_of_mem g (mem_filter.1 hx).1)]
    refine Finset.sum_congr rfl fun v _ => ?_
    rw [Finset.filter_filter]
    have hconst : ∀ x ∈ ({x ∈ s | k x = c ∧ g x = v} : Finset α),
        miTerm s g k x = Real.logb 2 (s.card : ℝ) - Real.logb 2 (#{x ∈ s | g x = v} : ℝ)
          - Real.logb 2 (#{x ∈ s | k x = c} : ℝ)
          + Real.logb 2 (#{x ∈ s | k x = c ∧ g x = v} : ℝ) := by
      intro x hx
      obtain ⟨-, hk, hg⟩ := (mem_filter.1 hx)
      simp only [miTerm, hk, hg]
    rw [Finset.sum_congr rfl hconst, Finset.sum_const, nsmul_eq_mul]
  rw [hfib, Finset.sum_div]
  refine Finset.sum_congr rfl fun c _ => ?_
  rw [Finset.sum_div]
  refine Finset.sum_congr rfl fun v _ => ?_
  ring

/-- On a sample point the pointwise density is the logarithm of a single ratio of counts. -/
theorem miTerm_eq_logb (s : Finset α) (g : α → β) (k : α → γ) {x : α} (hx : x ∈ s) :
    miTerm s g k x = Real.logb 2 ((s.card : ℝ) * #{y ∈ s | k y = k x ∧ g y = g x} /
      ((#{y ∈ s | g y = g x} : ℝ) * #{y ∈ s | k y = k x})) := by
  have h0 : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 ⟨x, hx⟩
  have h1 : (0 : ℝ) < #{y ∈ s | g y = g x} := by
    exact_mod_cast card_pos.2 ⟨x, by simp [hx]⟩
  have h2 : (0 : ℝ) < #{y ∈ s | k y = k x} := by
    exact_mod_cast card_pos.2 ⟨x, by simp [hx]⟩
  have h3 : (0 : ℝ) < #{y ∈ s | k y = k x ∧ g y = g x} := by
    exact_mod_cast card_pos.2 ⟨x, by simp [hx]⟩
  rw [miTerm, Real.logb_div (by positivity) (by positivity), Real.logb_mul h0.ne' h3.ne',
    Real.logb_mul h1.ne' h2.ne']
  ring

end Pointwise

/-- A read-out carries no uncertainty given itself. -/
theorem condEnt_self_eq_zero {α β : Type*} [DecidableEq β] {s : Finset α} (g : α → β) :
    condEnt s g g = 0 := by
  refine Finset.sum_eq_zero fun c _ => ?_
  have : uEnt {x ∈ s | g x = c} g = 0 := by
    rw [uEnt]
    have hfib : ∀ a ∈ ({x ∈ s | g x = c} : Finset α),
        Real.logb 2 (#{x ∈ {x ∈ s | g x = c} | g x = g a} : ℝ)
          = Real.logb 2 (#{x ∈ s | g x = c} : ℝ) := by
      intro a ha
      rw [(mem_filter.1 ha).2]
      congr 3
      exact Finset.filter_true_of_mem fun x hx => (mem_filter.1 hx).2
    rw [Finset.sum_congr rfl hfib, Finset.sum_const, nsmul_eq_mul]
    rcases Nat.eq_zero_or_pos (#{x ∈ s | g x = c}) with h0 | h0
    · simp [h0]
    · have : (#{x ∈ s | g x = c} : ℝ) ≠ 0 := by exact_mod_cast h0.ne'
      field_simp
      ring
  rw [this, mul_zero]

/-- Entropy is self-information. -/
theorem uEnt_eq_mutInfo_self {α β : Type*} [DecidableEq β] (s : Finset α) (g : α → β) :
    uEnt s g = mutInfo s g g := by
  rw [mutInfo, condEnt_self_eq_zero, sub_zero]

/-! ## 2. Uniform-fibre transport -/

section Transport

variable {Ω Ω' : Type*} [Fintype Ω] [Fintype Ω'] [DecidableEq Ω']

/-- A map with all fibres of size `K` multiplies every pulled-back count by `K`. -/
theorem card_filter_comp (f : Ω → Ω') (K : ℕ) (hf : ∀ y, #{x | f x = y} = K)
    (P : Ω' → Prop) [DecidablePred P] : #{x | P (f x)} = K * #{y | P y} := by
  classical
  rw [Finset.card_eq_sum_card_fiberwise (f := f) (t := {y | P y})
    (fun x hx => by simpa using hx)]
  have : ∀ y ∈ ({y | P y} : Finset Ω'), #{x ∈ ({x | P (f x)} : Finset Ω) | f x = y} = K := by
    intro y hy
    rw [← hf y, Finset.filter_filter]
    congr 1
    refine Finset.filter_congr fun x _ => ?_
    constructor
    · exact fun h => h.2
    · intro h; exact ⟨by rw [h]; simpa using hy, h⟩
  rw [Finset.sum_congr rfl this, Finset.sum_const, smul_eq_mul, mul_comm]

/-- A map with all fibres of size `K` multiplies the cardinality by `K`. -/
theorem card_eq_of_uniform_fibres (f : Ω → Ω') (K : ℕ) (hf : ∀ y, #{x | f x = y} = K) :
    Fintype.card Ω = K * Fintype.card Ω' := by
  have := card_filter_comp f K hf (fun _ => True)
  simpa using this

/-- Sums of pulled-back functions along a uniform-fibre map. -/
theorem sum_comp_of_uniform_fibres (f : Ω → Ω') (K : ℕ) (hf : ∀ y, #{x | f x = y} = K)
    (F : Ω' → ℝ) : ∑ x, F (f x) = K * ∑ y, F y := by
  classical
  rw [← Finset.sum_fiberwise_of_maps_to (s := univ) (t := univ) (g := f) (fun _ _ => mem_univ _),
    Finset.mul_sum]
  refine Finset.sum_congr rfl fun y _ => ?_
  have : ∀ x ∈ ({x | f x = y} : Finset Ω), F (f x) = F y := by
    intro x hx; rw [(mem_filter.1 hx).2]
  rw [Finset.sum_congr rfl this, Finset.sum_const, hf y, nsmul_eq_mul]

variable {β γ β' γ' : Type*} [DecidableEq β] [DecidableEq γ] [DecidableEq β'] [DecidableEq γ']

/-- **The transport theorem.**  Let `f : Ω → Ω'` have all fibres of the same size `K > 0`.
If at every sample point the pointwise mutual-information ratio of `(g, k)` on `Ω` equals the
ratio of `(g', k')` at the image point (stated as a cross-multiplied identity of natural
numbers), then the two mutual informations coincide. -/
theorem mutInfo_transport [Nonempty Ω'] (f : Ω → Ω') (K : ℕ) (hK : 0 < K)
    (hf : ∀ y, #{x | f x = y} = K)
    (g : Ω → β) (k : Ω → γ) (g' : Ω' → β') (k' : Ω' → γ')
    (hratio : ∀ x, Fintype.card Ω * #{y | k y = k x ∧ g y = g x}
        * #{y | g' y = g' (f x)} * #{y | k' y = k' (f x)}
      = Fintype.card Ω' * #{y | k' y = k' (f x) ∧ g' y = g' (f x)}
        * #{y | g y = g x} * #{y | k y = k x}) :
    mutInfo univ g k = mutInfo univ g' k' := by
  classical
  have hcard := card_eq_of_uniform_fibres f K hf
  have hΩ' : (univ : Finset Ω').Nonempty := univ_nonempty
  have hΩ : (univ : Finset Ω).Nonempty := by
    obtain ⟨y⟩ := (inferInstance : Nonempty Ω')
    have : 0 < #{x | f x = y} := by rw [hf y]; exact hK
    obtain ⟨x, -⟩ := card_pos.1 this
    exact ⟨x, mem_univ x⟩
  rw [mutInfo_eq_sum_miTerm _ _ _ hΩ, mutInfo_eq_sum_miTerm _ _ _ hΩ']
  have hpt : ∀ x, miTerm univ g k x = miTerm univ g' k' (f x) := by
    intro x
    rw [miTerm_eq_logb _ _ _ (mem_univ x), miTerm_eq_logb _ _ _ (mem_univ (f x))]
    congr 1
    have a1 : (0 : ℝ) < #{y | g y = g x} := by exact_mod_cast card_pos.2 ⟨x, by simp⟩
    have a2 : (0 : ℝ) < #{y | k y = k x} := by exact_mod_cast card_pos.2 ⟨x, by simp⟩
    have a3 : (0 : ℝ) < #{y | g' y = g' (f x)} := by
      exact_mod_cast card_pos.2 ⟨f x, by simp⟩
    have a4 : (0 : ℝ) < #{y | k' y = k' (f x)} := by
      exact_mod_cast card_pos.2 ⟨f x, by simp⟩
    have e := congrArg (Nat.cast (R := ℝ)) (hratio x)
    push_cast at e
    simp only [card_univ]
    rw [div_eq_div_iff (by positivity) (by positivity)]
    linarith [e]
  simp_rw [hpt]
  rw [sum_comp_of_uniform_fibres f K hf, card_univ, card_univ, hcard]
  push_cast
  have hK' : (K : ℝ) ≠ 0 := by exact_mod_cast hK.ne'
  rw [mul_div_mul_left _ _ hK']


/-- **Entropy transport.**  Pushing a read-out forward along a uniform-fibre map preserves its
entropy. -/
theorem uEnt_transport [Nonempty Ω'] (f : Ω → Ω') (K : ℕ) (hK : 0 < K)
    (hf : ∀ y, #{x | f x = y} = K) (g' : Ω' → β') :
    uEnt univ (fun x => g' (f x)) = uEnt univ g' := by
  classical
  rw [uEnt_eq_mutInfo_self univ (fun x => g' (f x)), uEnt_eq_mutInfo_self univ g']
  refine mutInfo_transport f K hK hf _ _ g' g' fun x => ?_
  simp only [and_self]
  rw [card_filter_comp f K hf (fun y => g' y = g' (f x)), card_eq_of_uniform_fibres f K hf]
  ring

end Transport

/-! ## 3. The hint value and its size-stability -/

section SizeStability

variable {Ω : Type*} [Fintype Ω] {Λ W V : Type*} [DecidableEq Λ] [DecidableEq W] [DecidableEq V]

/-- The **hint value** of a battery with label `L`: what the factor-pair view `P` carries about
the label beyond the product view `N`, `I(L ; P) - I(L ; N)`, in bits. -/
noncomputable def hint (L : Ω → Λ) (P : Ω → W) (N : Ω → V) : ℝ :=
  mutInfo univ L P - mutInfo univ L N

omit [DecidableEq Λ] [DecidableEq W] [DecidableEq V] in
/-- Counting on a product: a condition on the first coordinate. -/
theorem card_filter_fst {A F : Type*} [Fintype A] [Fintype F] (P : A → Prop) [DecidablePred P] :
    #{z : A × F | P z.1} = #{a | P a} * Fintype.card F := by
  classical
  rw [show (univ.filter fun z : A × F => P z.1) = (univ.filter P) ×ˢ (univ : Finset F) by
    ext z; simp, card_product, card_univ]

omit [DecidableEq Λ] [DecidableEq W] [DecidableEq V] in
/-- Counting on a product: the first coordinate pinned, a condition on the second. -/
theorem card_filter_fst_eq {A F : Type*} [Fintype A] [DecidableEq A] [Fintype F] (a : A)
    (P : F → Prop) [DecidablePred P] :
    #{z : A × F | z.1 = a ∧ P z.2} = #{c | P c} := by
  classical
  rw [show (univ.filter fun z : A × F => z.1 = a ∧ P z.2) = {a} ×ˢ (univ.filter P) by
    ext ⟨a', c⟩; simp only [mem_product, mem_filter, mem_univ, true_and, mem_singleton],
    card_product, card_singleton, one_mul]

/-- **Size-stability (uniform blow-up invariance).**  Replace every sample of a battery by
`|F|` indistinguishable copies (`F` any non-empty finite set of "prime identities" per residue
class), with label and views depending only on the class.  Every mutual information, and hence
the hint value, is unchanged: the hint value is a function of the class-level law alone. -/
theorem mutInfo_blowup {F : Type*} [Fintype F] [Nonempty F] [Nonempty Ω] [DecidableEq Ω]
    (L : Ω → Λ) (P : Ω → W) :
    mutInfo univ (fun x : Ω × F => L x.1) (fun x => P x.1) = mutInfo univ L P := by
  classical
  have hF : 0 < Fintype.card F := Fintype.card_pos
  have hf : ∀ y : Ω, #{x : Ω × F | x.1 = y} = Fintype.card F := by
    intro y
    have := card_filter_fst (F := F) (fun a : Ω => a = y)
    simpa [Finset.filter_eq'] using this
  refine mutInfo_transport Prod.fst _ hF hf _ _ L P fun x => ?_
  rw [card_filter_comp Prod.fst _ hf (fun y => P y = P x.1 ∧ L y = L x.1),
    card_filter_comp Prod.fst _ hf (fun y => L y = L x.1),
    card_filter_comp Prod.fst _ hf (fun y => P y = P x.1), Fintype.card_prod]
  ring

/-- **The hint value is size-stable**: uniform replication of the residue classes leaves it
exactly fixed. -/
theorem hint_blowup {F : Type*} [Fintype F] [Nonempty F] [Nonempty Ω] [DecidableEq Ω]
    (L : Ω → Λ) (P : Ω → W) (N : Ω → V) :
    hint (fun x : Ω × F => L x.1) (fun x => P x.1) (fun x => N x.1) = hint L P N := by
  rw [hint, hint, mutInfo_blowup, mutInfo_blowup]

end SizeStability

/-! ## 4. The residue-lift theorem: the hint value lives on the dial -/

section ResidueLift

variable {G H C Λ : Type*} [CommGroup G] [Fintype G] [DecidableEq G] [CommGroup H] [Fintype H]
  [DecidableEq H] [Fintype C] [DecidableEq C] [DecidableEq Λ]

/-- The **dial map** from the residue box `(p mod m, q mod m, Frobenius coin)` to the dial box
`(ψ p, ψ q, coin)`. -/
def dialMap (ψ : G →* H) (x : (G × G) × C) : (H × H) × C := ((ψ x.1.1, ψ x.1.2), x.2)

/-- A label that sees the residues only through the dial `ψ` (plus an independent coin). -/
def liftLabel (ψ : G →* H) (ℓ : H × H → C → Λ) (x : (G × G) × C) : Λ :=
  ℓ (ψ x.1.1, ψ x.1.2) x.2

/-- The same label on the dial box. -/
def dialLabel (ℓ : H × H → C → Λ) (y : (H × H) × C) : Λ := ℓ y.1 y.2

/-- The factor-pair view `(p mod m, q mod m)`. -/
def pairView {A : Type*} (x : (A × A) × C) : A × A := x.1

/-- The product view `N mod m = p q mod m`. -/
def prodView {A : Type*} [Mul A] (x : (A × A) × C) : A := x.1.1 * x.1.2

omit [Fintype G] [DecidableEq G] [Fintype H] [DecidableEq H] [Fintype C] [DecidableEq C]
  [DecidableEq Λ] in
theorem liftLabel_eq (ψ : G →* H) (ℓ : H × H → C → Λ) (x : (G × G) × C) :
    liftLabel ψ ℓ x = dialLabel ℓ (dialMap ψ x) := rfl

/-- The common fibre size of a surjective dial. -/
def kerCard (ψ : G →* H) : ℕ := #{a | ψ a = 1}

omit [Fintype H] [DecidableEq G] in
theorem card_fiber_dial (ψ : G →* H) (hψ : Function.Surjective ψ) (h : H) :
    #{a | ψ a = h} = kerCard ψ :=
  MonoidHom.card_fiber_eq_of_mem_range ψ (hψ h) ⟨1, map_one ψ⟩

omit [DecidableEq G] [Fintype H] in
theorem kerCard_pos (ψ : G →* H) : 0 < kerCard ψ := card_pos.2 ⟨1, by simp⟩

omit [DecidableEq G] in
theorem card_eq_kerCard_mul (ψ : G →* H) (hψ : Function.Surjective ψ) :
    Fintype.card G = kerCard ψ * Fintype.card H :=
  card_eq_of_uniform_fibres ψ _ (card_fiber_dial ψ hψ)

omit [DecidableEq Λ] [Fintype H] [DecidableEq G] in
theorem card_fiber_dialMap (ψ : G →* H) (hψ : Function.Surjective ψ) (y : (H × H) × C) :
    #{x | dialMap ψ x = y} = kerCard ψ ^ 2 := by
  classical
  rw [show (univ.filter fun x : (G × G) × C => dialMap ψ x = y)
      = ((univ.filter fun a => ψ a = y.1.1) ×ˢ (univ.filter fun a => ψ a = y.1.2)) ×ˢ {y.2} by
    ext ⟨⟨a, b⟩, c⟩
    obtain ⟨⟨h1, h2⟩, c'⟩ := y
    simp only [mem_filter, mem_univ, true_and, mem_product, mem_singleton, dialMap,
      Prod.mk.injEq], card_product, card_product, card_singleton,
    card_fiber_dial ψ hψ, card_fiber_dial ψ hψ, sq, mul_one]

omit [Fintype H] in
/-- Factorisations of a fixed residue `n` with prescribed dial values: there are exactly
`|ker ψ|` of them when the dial values are compatible with `ψ n`. -/
theorem card_factorisations (ψ : G →* H) (hψ : Function.Surjective ψ) (n : G) (h1 h2 : H)
    (hc : h1 * h2 = ψ n) :
    #{z : G × G | z.1 * z.2 = n ∧ ψ z.1 = h1 ∧ ψ z.2 = h2} = kerCard ψ := by
  classical
  rw [← card_fiber_dial ψ hψ h1]
  refine Finset.card_nbij' Prod.fst (fun a => (a, a⁻¹ * n)) ?_ ?_ ?_ ?_
  · intro z hz
    simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hz ⊢
    exact hz.2.1
  · intro a ha
    simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at ha ⊢
    refine ⟨by group, ha, ?_⟩
    rw [map_mul, map_inv, ha, ← hc]
    group
  · intro z hz
    simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hz
    ext
    · rfl
    · simp only
      rw [← hz.1]; group
  · intro a _; rfl

variable [Nonempty C]

/-- **Pair row of the residue lift**: `I(L ; p mod m, q mod m) = I(L ; ψ p, ψ q)`. -/
theorem mutInfo_pair_lift (ψ : G →* H) (hψ : Function.Surjective ψ) (ℓ : H × H → C → Λ) :
    mutInfo univ (liftLabel ψ ℓ) (pairView (C := C)) = mutInfo univ (dialLabel ℓ) pairView := by
  classical
  have hf := card_fiber_dialMap (C := C) ψ hψ
  have hK : 0 < kerCard ψ ^ 2 := pow_pos (kerCard_pos ψ) 2
  refine mutInfo_transport (dialMap ψ) _ hK hf _ _ _ _ fun x => ?_
  have hcard := card_eq_of_uniform_fibres (dialMap ψ (C := C)) _ hf
  have e1 : #{y : (G × G) × C | pairView y = pairView x ∧ liftLabel ψ ℓ y = liftLabel ψ ℓ x}
      = #{c : C | ℓ (ψ x.1.1, ψ x.1.2) c = liftLabel ψ ℓ x} := by
    rw [← card_filter_fst_eq (F := C) x.1 (fun c => ℓ (ψ x.1.1, ψ x.1.2) c = liftLabel ψ ℓ x)]
    congr 1
    refine Finset.filter_congr fun y _ => ?_
    constructor
    · rintro ⟨h1, h2⟩
      refine ⟨h1, ?_⟩
      simp only [pairView] at h1
      simpa [liftLabel, h1] using h2
    · rintro ⟨h1, h2⟩
      refine ⟨h1, ?_⟩
      simp only [liftLabel, h1]
      exact h2
  have e2 : #{y : (H × H) × C | pairView y = pairView (dialMap ψ x) ∧
      dialLabel ℓ y = dialLabel ℓ (dialMap ψ x)}
      = #{c : C | ℓ (ψ x.1.1, ψ x.1.2) c = liftLabel ψ ℓ x} := by
    rw [← card_filter_fst_eq (F := C) (dialMap ψ x).1
      (fun c => ℓ (ψ x.1.1, ψ x.1.2) c = liftLabel ψ ℓ x)]
    congr 1
    refine Finset.filter_congr fun y _ => ?_
    constructor
    · rintro ⟨h1, h2⟩
      refine ⟨h1, ?_⟩
      simp_all [pairView, dialLabel, dialMap, liftLabel]
    · rintro ⟨h1, h2⟩
      refine ⟨h1, ?_⟩
      simp_all [pairView, dialLabel, dialMap, liftLabel]
  have e3 : #{y : (G × G) × C | pairView y = pairView x} = Fintype.card C := by
    have := card_filter_fst_eq (F := C) x.1 (fun _ => True)
    simpa [pairView] using this
  have e4 : #{y : (H × H) × C | pairView y = pairView (dialMap ψ x)} = Fintype.card C := by
    have := card_filter_fst_eq (F := C) (dialMap ψ x).1 (fun _ => True)
    simpa [pairView] using this
  have e5 : #{y : (G × G) × C | liftLabel ψ ℓ y = liftLabel ψ ℓ x}
      = kerCard ψ ^ 2 * #{y | dialLabel ℓ y = dialLabel ℓ (dialMap ψ x)} :=
    card_filter_comp (dialMap ψ) _ hf (fun y => dialLabel ℓ y = dialLabel ℓ (dialMap ψ x))
  rw [e1, e2, e3, e4, e5, hcard]
  ring

omit [Nonempty C] [DecidableEq C] in
theorem card_prodView (n : G) :
    #{y : (G × G) × C | prodView y = n} = Fintype.card G * Fintype.card C := by
  classical
  have := card_filter_fst (A := G × G) (F := C) (fun z : G × G => z.1 * z.2 = n)
  simp only [prodView]
  rw [this]
  congr 1
  rw [← card_univ (α := G)]
  refine Finset.card_nbij' Prod.fst (fun a => (a, a⁻¹ * n)) ?_ ?_ ?_ ?_
  · intro z _; simp
  · intro a _; simp
  · intro z hz
    simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hz
    ext
    · rfl
    · simp only
      rw [← hz]; group
  · intro a _; rfl

/-- **Product row of the residue lift**: `I(L ; N mod m) = I(L ; ψ N)`. -/
theorem mutInfo_prod_lift (ψ : G →* H) (hψ : Function.Surjective ψ) (ℓ : H × H → C → Λ) :
    mutInfo univ (liftLabel ψ ℓ) (prodView (C := C)) = mutInfo univ (dialLabel ℓ) prodView := by
  classical
  have hf := card_fiber_dialMap (C := C) ψ hψ
  have hK : 0 < kerCard ψ ^ 2 := pow_pos (kerCard_pos ψ) 2
  refine mutInfo_transport (dialMap ψ) _ hK hf _ _ _ _ fun x => ?_
  have hcard := card_eq_of_uniform_fibres (dialMap ψ (C := C)) _ hf
  have hG := card_eq_kerCard_mul ψ hψ
  set n := prodView x with hn
  set lam := liftLabel ψ ℓ x with hlam
  have hpn : prodView (dialMap ψ x) = ψ n := by
    simp [prodView, dialMap, hn, map_mul]
  have hll : dialLabel ℓ (dialMap ψ x) = lam := rfl
  rw [hpn, hll]
  -- the joint count on the residue box
  have e1 : #{y : (G × G) × C | prodView y = n ∧ liftLabel ψ ℓ y = lam}
      = kerCard ψ * #{y : (H × H) × C | prodView y = ψ n ∧ dialLabel ℓ y = lam} := by
    rw [Finset.card_eq_sum_card_fiberwise (f := dialMap ψ)
      (t := {y : (H × H) × C | prodView y = ψ n ∧ dialLabel ℓ y = lam}) ?_]
    · rw [mul_comm, ← smul_eq_mul, ← Finset.sum_const]
      refine Finset.sum_congr rfl fun y hy => ?_
      simp only [mem_filter, mem_univ, true_and] at hy
      obtain ⟨⟨h1, h2⟩, c⟩ := y
      simp only [prodView, dialLabel] at hy
      rw [← card_factorisations ψ hψ n h1 h2 hy.1, Finset.filter_filter,
        ← mul_one (#{z : G × G | z.1 * z.2 = n ∧ ψ z.1 = h1 ∧ ψ z.2 = h2}),
        show (1 : ℕ) = #({c} : Finset C) from (card_singleton c).symm, ← card_product]
      congr 1
      ext ⟨⟨a, b⟩, c'⟩
      simp only [mem_filter, mem_univ, true_and, mem_product, mem_singleton, prodView, dialMap,
        liftLabel, Prod.mk.injEq]
      constructor
      · rintro ⟨⟨hab, -⟩, ⟨ha, hb⟩, hc⟩
        exact ⟨⟨hab, ha, hb⟩, hc⟩
      · rintro ⟨⟨hab, ha, hb⟩, hc⟩
        refine ⟨⟨hab, ?_⟩, ⟨ha, hb⟩, hc⟩
        rw [ha, hb, hc]; exact hy.2
    · intro z hz
      simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hz ⊢
      refine ⟨?_, hz.2⟩
      simp [prodView, dialMap, ← hz.1, map_mul]
  have e2 : #{y : (G × G) × C | liftLabel ψ ℓ y = lam}
      = kerCard ψ ^ 2 * #{y | dialLabel ℓ y = lam} :=
    card_filter_comp (dialMap ψ) _ hf (fun y => dialLabel ℓ y = lam)
  rw [e1, e2, card_prodView, card_prodView, hcard, hG]
  ring

/-- **The residue-lift theorem.**  For any finite abelian conductor group `G` (e.g.
`(ℤ/m*)ˣ`), any surjective dial `ψ : G → H` and any label that sees the factor residues only
through the dial plus an independent Frobenius coin, the hint value read on the residue views
`(p mod m*, q mod m*)` and `N mod m*` equals the hint value of the small dial box. -/
theorem hint_residue_lift (ψ : G →* H) (hψ : Function.Surjective ψ) (ℓ : H × H → C → Λ) :
    hint (liftLabel ψ ℓ) (pairView (C := C)) prodView
      = hint (dialLabel ℓ) pairView prodView := by
  rw [hint, hint, mutInfo_pair_lift ψ hψ, mutInfo_prod_lift ψ hψ]

end ResidueLift

/-! ## 5. Residual entropy: abelian labels and the pool-floor ceiling -/

section Residual

variable {α Λ W V : Type*} [DecidableEq Λ] [DecidableEq W] [DecidableEq V]

omit [DecidableEq W] [DecidableEq V] in
/-- A read-out that is constant on `t` has zero entropy there. -/
theorem uEnt_eq_zero_of_const (t : Finset α) (L : α → Λ) (h : ∀ x ∈ t, ∀ y ∈ t, L x = L y) :
    uEnt t L = 0 := by
  have hfib : ∀ a ∈ t, Real.logb 2 (#{x ∈ t | L x = L a} : ℝ) = Real.logb 2 (t.card : ℝ) := by
    intro a ha
    congr 2
    exact congrArg Finset.card (Finset.filter_true_of_mem fun x hx => h x hx a ha)
  rw [uEnt, Finset.sum_congr rfl hfib, Finset.sum_const, nsmul_eq_mul]
  rcases Nat.eq_zero_or_pos t.card with h0 | h0
  · simp [h0]
  · have : (t.card : ℝ) ≠ 0 := by exact_mod_cast h0.ne'
    field_simp
    ring

omit [DecidableEq V] in
/-- **Residual entropy of a residue function is exactly zero.**  If the label is a function of
the view `P` on `s`, then `H(L | P) = 0`. -/
theorem condEnt_eq_zero_of_factor (s : Finset α) (L : α → Λ) (P : α → W) (ℓ : W → Λ)
    (h : ∀ x ∈ s, L x = ℓ (P x)) : condEnt s L P = 0 := by
  refine Finset.sum_eq_zero fun c _ => ?_
  rw [uEnt_eq_zero_of_const, mul_zero]
  intro x hx y hy
  rw [mem_filter] at hx hy
  rw [h x hx.1, h y hy.1, hx.2, hy.2]

omit [DecidableEq V] in
/-- If the label is a residue function of `P`, the view `P` carries the whole label entropy. -/
theorem mutInfo_eq_uEnt_of_residue_function (s : Finset α) (L : α → Λ) (P : α → W)
    (ℓ : W → Λ) (h : ∀ x ∈ s, L x = ℓ (P x)) : mutInfo s L P = uEnt s L := by
  rw [mutInfo, condEnt_eq_zero_of_factor s L P ℓ h, sub_zero]

variable {Ω : Type*} [Fintype Ω]

/-- **The hint value is the released conditional entropy minus the residual.**
`hint = H(L | N) - H(L | P)`. -/
theorem hint_eq_sub_residual (L : Ω → Λ) (P : Ω → W) (N : Ω → V) :
    hint L P N = condEnt univ L N - condEnt univ L P := by
  rw [hint, mutInfo, mutInfo]; ring

/-- The residual entropy is never negative. -/
theorem condEnt_nonneg' (s : Finset α) (L : α → Λ) (P : α → W) : 0 ≤ condEnt s L P := by
  have := mutInfo_le_uEnt s L P
  rw [mutInfo] at this
  linarith

/-- **The pool-floor ceiling.**  Whatever the pool, the hint value never exceeds the label
uncertainty left by the product view: `hint ≤ H(L | N)`. -/
theorem hint_le_condEnt (L : Ω → Λ) (P : Ω → W) (N : Ω → V) :
    hint L P N ≤ condEnt univ L N := by
  rw [hint_eq_sub_residual]
  linarith [condEnt_nonneg' (univ : Finset Ω) L P]

/-- **Abelian dials: the residual vanishes.**  If the label is a residue function of the pair
view (as for every abelian field, whose splitting type is read off `p mod m*`), the hint value
is exactly the released entropy `H(L | N)`. -/
theorem hint_eq_condEnt_of_residue_function (L : Ω → Λ) (P : Ω → W) (N : Ω → V) (ℓ : W → Λ)
    (h : ∀ x, L x = ℓ (P x)) : hint L P N = condEnt univ L N := by
  rw [hint_eq_sub_residual, condEnt_eq_zero_of_factor univ L P ℓ fun x _ => h x, sub_zero]

/-- **The pool-floor exception, formally.**  If the pair view separates the pool (at most one
prime per residue-pair class), the label is automatically a residue function and the hint value
is pushed all the way to the ceiling `H(L | N)` — for *any* label, abelian or not.  The excess
over the population value is exactly the population residual `H(L | P)`. -/
theorem hint_eq_condEnt_of_injective (L : Ω → Λ) (P : Ω → W) (N : Ω → V)
    (hP : Function.Injective P) : hint L P N = condEnt univ L N := by
  rw [hint_eq_sub_residual, condEnt_eq_zero_of_injOn L (Set.injOn_of_injective hP), sub_zero]

end Residual

/-! ## 6. The which-factor wall -/

section Wall

variable {Ω : Type*} [Fintype Ω] {W : Type*} [DecidableEq W]

/-- An orientation bit flipped by an involution splits every invariant event exactly in half. -/
theorem card_orient_half (σ : Ω → Ω) (hσ : Function.Involutive σ) (O : Ω → Bool)
    (hO : ∀ x, O (σ x) = !O x) (Q : Ω → Prop) [DecidablePred Q] (hQ : ∀ x, Q (σ x) ↔ Q x)
    (b : Bool) : 2 * #{x | Q x ∧ O x = b} = #{x | Q x} := by
  have e : #{x | Q x ∧ O x = b} = #{x | Q x ∧ O x = !b} := by
    refine Finset.card_nbij' σ σ ?_ ?_ ?_ ?_
    · intro x hx
      simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hx ⊢
      rw [hQ, hO, hx.2]; exact ⟨hx.1, rfl⟩
    · intro x hx
      simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hx ⊢
      rw [hQ, hO, hx.2]; exact ⟨hx.1, by simp⟩
    · intro x _; exact hσ x
    · intro x _; exact hσ x
  have hsplit := Finset.card_filter_add_card_filter_not (s := univ.filter Q)
    (fun x => O x = b)
  simp only [Finset.filter_filter] at hsplit
  have hQeta : #(univ.filter Q) = #{x | Q x} := rfl
  have hneg : #{x | Q x ∧ ¬O x = b} = #{x | Q x ∧ O x = !b} := by
    congr 1
    refine Finset.filter_congr fun x _ => ?_
    cases O x <;> cases b <;> simp
  omega

/-- **THE WHICH-FACTOR WALL.**  Let `σ` be the factor swap `(p, q) ↦ (q, p)` of a
swap-invariant battery, `O` any orientation bit (`O ∘ σ = ¬O`) and `V` any symmetric view
(`V ∘ σ = V`), e.g. `V = (N mod m*, unordered residue pair, unordered type pair)`.  Then
`I(O ; V) = 0` exactly: conditional on the symmetric data the orientation is a fair coin.  This
is the exact null of the conditional orientation-permutation instrument. -/
theorem which_factor_wall (σ : Ω → Ω) (hσ : Function.Involutive σ) (O : Ω → Bool)
    (hO : ∀ x, O (σ x) = !O x) (V : Ω → W) (hV : ∀ x, V (σ x) = V x) :
    mutInfo univ O V = 0 := by
  classical
  rcases isEmpty_or_nonempty Ω with hΩ | hΩ
  · simp [mutInfo, uEnt, condEnt]
  rw [mutInfo_eq_sum_miTerm _ _ _ univ_nonempty]
  have hz : ∀ x, miTerm univ O V x = 0 := by
    intro x
    rw [miTerm_eq_logb _ _ _ (mem_univ x)]
    have h1 := card_orient_half σ hσ O hO (fun _ => True) (fun _ => Iff.rfl) (O x)
    have h2 := card_orient_half σ hσ O hO (fun y => V y = V x)
      (fun y => by show V (σ y) = V x ↔ V y = V x; rw [hV]) (O x)
    simp only [true_and, Finset.filter_true, card_univ] at h1
    have h1' : (2 : ℝ) * #{y | O y = O x} = Fintype.card Ω := by exact_mod_cast h1
    have h2' : (2 : ℝ) * #{y | V y = V x ∧ O y = O x} = #{y | V y = V x} := by
      exact_mod_cast h2
    have hb : (0 : ℝ) < #{y | O y = O x} := by exact_mod_cast card_pos.2 ⟨x, by simp⟩
    have hc : (0 : ℝ) < #{y | V y = V x} := by exact_mod_cast card_pos.2 ⟨x, by simp⟩
    have key : ((univ : Finset Ω).card : ℝ) * #{y | V y = V x ∧ O y = O x} /
        ((#{y | O y = O x} : ℝ) * #{y | V y = V x}) = 1 := by
      rw [card_univ, div_eq_one_iff_eq (by positivity), ← h1', ← h2']
      ring
    rw [key, Real.logb_one]
  simp [hz]

/-- **The instrument lesson.**  An *unconditional* orientation statistic is not protected by
the wall: on the two-sample battery `{(2,3), (3,2)}` with orientation `O = [p < q]`, the naive
statistic `I(O ; p mod 5)` reads a full bit, while the conditional statistic holding the
symmetric data `(N mod 5, {p, q} mod 5)` fixed reads exactly `0`. -/
theorem naive_instrument_fails :
    let p : Fin 2 → ℕ := ![2, 3]
    let q : Fin 2 → ℕ := ![3, 2]
    let O : Fin 2 → Bool := fun i => decide (p i < q i)
    mutInfo univ O (fun i => p i % 5) = 1 ∧
      mutInfo univ O (fun i => (p i * q i % 5, min (p i % 5) (q i % 5), max (p i % 5) (q i % 5)))
        = 0 := by
  intro p q O
  constructor
  · rw [mutInfo, condEnt_eq_zero_of_injOn O (Set.injOn_of_injective (by decide)),
      uEnt_eq_countSum _ _ (↑[1, 1] : Multiset ℕ) (by decide)]
    simp
  · refine which_factor_wall Fin.rev (fun i => Fin.rev_rev i) O (by decide) _ (by decide)

end Wall

end HintSizeScaling